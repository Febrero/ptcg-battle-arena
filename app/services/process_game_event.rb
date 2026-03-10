class ProcessGameEvent < ApplicationService
  attr_reader :game_mode

  SUFFIX_START_LOG = "-startlog"

  def call game_details
    Rails.logger.info "Persisting game event: #{game_details["GameId"]}"
    # this is only to ensure that all matchtype is well defined should be revised and removed when game and backend are sure about this
    # we receive an airbrake error because of this https://realfevr.airbrake.io/projects/408870/groups/3648188606043022180?tab=overview
    # game_details["MatchType"] = "PVE" if game_details["GameModeId"].to_i == -1
    # game_details["MatchType"] = "PVP" if game_details["GameModeId"].to_i == -2

    # if game_details["GameMode"] == "Playoff" && game_details["CurrentBracketId"]
    #   playoff = Playoffs::Bracket.find(game_details["CurrentBracketId"]).playoff
    #   game_details["GameModeId"] = playoff.uid
    # end

    is_game_end_log = game_details["IsEndLog"].nil? ? true : game_details["IsEndLog"]

    game_details_state = is_game_end_log ? "game_end_log" : "game_start_log"

    if is_game_end_log
      # only set redis processing key if its a end game log
      # this key is used to give a state in rewards controller to know if game is already processed or not
      #    maybe the battle arena  is asking for rewards before we process the game
      get_redis.set("#{game_details["GameId"]}::processing", "1", ex: (3 * 3600))
    end

    game = Game.where(game_id: game_details["GameId"]).first

    @game_mode = GameMode.where(uid: game_details["GameModeId"]).first

    game_details["Season"] = Season.currently_active.first.try(:uid)

    game_already_exists = game.present?
    persisted_game_state = nil
    if !game_already_exists
      game_data = base_game(game_details, game_details_state)
      game = Game.create!(game_data)

      AssistedGamers::IncrementDailyGame.call(game_data[:players_wallet_addresses])
    else
      persisted_game_state = game.state
      game.update(base_game(game_details, game_details_state))
    end

    game_id = game.id
    game_details["Players"].each do |player_details|
      game_player = GamePlayer
        .where(game_id: game_id, wallet_addr: player_details["WalletAddr"])
        .first_or_create(
          base_game_player(game_id, player_details)
        )

      game_player.update(base_game_player(game_id, player_details)) if game_details["Correction"] || game_details["IsEndLog"] == true || persisted_game_state == "game_start_log"

      SetBanPeriod.call(game_player.wallet_addr, game.game_id) if game_player.resigned?
    end

    # return if is a start log we only want persist game and players, to have something from our side that game really started
    return if !is_game_end_log

    # check if game already exists and is a end log or a game already exist is pre feature start game, if so, we should not process it again
    # raise GameAlreadyProcessed, if:
    #  - game already exists +  game has game_end_log state on database + game does not have correction flag
    #  - game already exists +  game does not have state on database (OLD IMPLEMENTATION) + game does not have correction flag

    if game_already_exists && (persisted_game_state == "game_end_log" || persisted_game_state.nil?) && !game_details["Correction"]
      Airbrake.notify(GameAlreadyProcessed.new(game))
      return
    end

    case game_details["GameMode"]
    when "Arena"
      Arenas::ProcessGame.call(game, game_details)
      # Currently we are not considering PVP and PVE games in UserActivty
      game_details["Players"].each do |player|
        UserActivity.where(
          wallet_addr: player["WalletAddr"],
          event_info: {game_id: game.game_id},
          source: game.game_mode
        ).first_or_create(
          season_uid: Season.currently_active.first.uid,
          event_date: Time.now
        )
      end
    when "Survival"
      Survivals::ProcessGame.call(game, game_details)
    when "Playoff"
      Playoffs::ProcessGame.call(game, game_details)
    end

    # Bail out if the round number is 0 ( one player resigned before the game started )
    # Shouldn't generate xp nor leaderboards events
    return if (game_details["RoundNumber"] == 0 && game_details["GameMode"] != "Playoff") || (game_mode.present? && game_mode.admin_only?)

    # we only need NFTstats for the top moments
    game_details_lite = game_details.deep_dup
    game_details_lite["Players"].each do |element|
      element.except!("NFTStats")
    end

    send_nft_stats = false
    if !(game_details["RoundNumber"] == 0 && game_details["GameMode"] == "Playoff")
      send_nft_stats = true

      if game_details_state == "game_end_log" && !game_details["Correction"]
        GenerateXpPoints.call(game_details_lite) if should_generate_xp?(game_details)
        RegisterQuestMilestones.call(game_details_lite)
        GenerateGreyCardRewards.call(game_details_lite) if should_generate_grey_card_rewards?(game_details)
      end
    end

    unless tutorial_game?(game_details)
      SendGameNftsStatsToKafka.call(game_details) if send_nft_stats
      SendGameEventToLeaderboardsKafka.call(game_details_lite)
    end
    SendGameEventToKafka.call(game_details_lite)
  rescue => e
    Rails.logger.info "ERROR WHILE PROCESSING GAME:\n#{game_details}"
    Rails.logger.info e.message
    Rails.logger.info e.backtrace.join("\n")

    Airbrake.notify(e)
  ensure
    get_redis.del("#{game_details["GameId"]}::processing") if game_details&.has_key?("GameId")
  end

  def base_game game_details, game_details_state
    players_wallet_addresses = game_details["Players"].map { |player| player["WalletAddr"] }
    winner = game_details["Players"].detect { |player| won_game(player["Outcome"]) }&.[]("WalletAddr")
    any_player_resigned = game_details["Players"].any? { |player| player["Resigned"] }

    {
      game_id: game_details["GameId"],
      game_log_id: game_details["GameLogId"],
      match_type: game_details["MatchType"],
      season: game_details["Season"],
      game_start_time: game_details["GameStartTime"],
      game_end_time: game_details["GameEndTime"],
      game_duration: game_details["GameDuration"],
      penalty_shootout: game_details["PenaltyShootout"],
      golden_goal: game_details["GoldenGoal"],
      overtime: game_details["Overtime"],
      round_number: game_details["RoundNumber"],
      turn_number: game_details["TurnNumber"],
      game_mode_id: game_details["GameModeId"],
      players_wallet_addresses: players_wallet_addresses,
      winner: winner,
      any_player_resigned: any_player_resigned,
      game_end_reason: game_details["MatchEndReasonString"],
      tiebreaker_criteria: game_details["TiebreakerCriteria"],
      state: game_details_state
    }
  end

  def base_game_player(game_id, player_details)
    {
      wallet_addr: player_details["WalletAddr"],
      game_id: game_id,
      deck_id: player_details["DeckId"],
      ticket_id: player_details["TicketId"],
      ticket_amount: game_mode&.ticket_amount_needed || player_details["TicketAmount"] || 0, # this fallback ensure that also pve and pvp will put the ticket amount sent by game endlog or 0 if not sent
      outcome: player_details["Outcome"],
      goals_scored: player_details["GoalsScored"],
      goals_conceded: player_details["GoalsConceded"],
      killcount: player_details["Killcount"],
      hattricks: player_details["Hattricks"],
      saves: player_details["Saves"],
      deck_power: player_details["DeckPower"],
      deck_level: player_details["DeckLevel"],
      rank_before_game: player_details["RankBeforeGame"],
      winner: won_game(player_details["Outcome"]),
      resigned: player_details["Resigned"]
    }
  end

  def won_game(outcome)
    ["2", "win", "w"].include? outcome.to_s.downcase
  end

  def should_generate_xp?(game_details)
    ["Arena", "PVE", "PVP", "Playoff", "Survival", "TutorialFriendly"].include?(game_details["MatchType"])
  end

  def should_generate_grey_card_rewards?(game_details)
    tutorial_game?(game_details)
  end

  def tutorial_game?(game_details)
    ["TutorialTraining", "TutorialFriendly"].include?(game_details["MatchType"]) && !player_resigned?(game_details)
  end

  def player_resigned?(game_details)
    game_details["Players"].map { |p| p["Resigned"] }.inject(false) { |acc, elm|
      acc ||= elm
      acc
    }
  end
end
