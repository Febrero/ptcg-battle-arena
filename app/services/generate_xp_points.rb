class GenerateXpPoints < ApplicationService
  attr_accessor :game_details, :deck_powers, :player_resigned, :xp_points_detailed

  def call game_details
    Rails.logger.info "Generating xp points for game: #{game_details["GameId"]}"

    @game_details = game_details
    @deck_powers = game_details["Players"].map { |player| player["DeckPower"] }
    @player_resigned = game_details["Players"].each_with_object({}) do |player, hash|
      hash[player["WalletAddr"]] = player["Resigned"]
    end

    game_details["Players"].each do |game_player|
      next if game_player["WalletAddr"].blank?
      @xp_points_detailed = {}
      Rails.logger.info "\tGenerating for player: #{game_player["WalletAddr"]}"

      begin
        rewards_value = calculate_xp_points_in_game(game_player)
        game_player["GameXp"] = rewards_value
        game_player["xp_detailed"] = xp_points_detailed
        reward = Rewards::Reward.create(wallet_addr:         game_player["WalletAddr"],
          value:               rewards_value,
          reward_type:         "xp",
          source:              "battle_arena",
          game_id:             game_details["GameId"],
          arena:               game_details["GameModeId"],
          game_mode:           game_details["GameMode"],
          game_mode_id:        game_details["GameModeId"],
          season:              game_details["Season"],
          event_detail:        game_player,
          event_type:          game_details["GameMode"],
          is_correction_event: false)

        claim_reward(reward)
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
        # ensure that will loop to the next iteration (player)
        Airbrake.notify("GENERATE XP POINTS", {
          game_id: game_details["GameId"],
          wallet_addr: game_player["WalletAddr"],
          exception_message: e.message
        })
      end
    end
  end

  private

  def player_resigned? game_player
    @player_resigned.present? && @player_resigned[game_player["WalletAddr"]]
  end

  def any_player_resigned?
    @player_resigned.present? && @player_resigned.values.any?
  end

  def won_game(outcome)
    ["2", "win", "w"].include? outcome.to_s.downcase
  end

  def calculate_xp_points_in_game game_player
    total_points = get_play_points(game_player)

    total_points += get_win_points(game_player) if won_game(game_player["Outcome"])

    total_points += get_misc_points(game_player) if !player_resigned?(game_player)

    total_points
  end

  def get_play_points game_player
    play_points = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:play]).achievement_value

    if player_resigned?(game_player)
      play_points = case "#{game_details["RoundNumber"]}-#{game_details["TurnNumber"]}"
      when "1-1", "1-2", "1-3"
        0
      when "1-4", "2-1", "2-2"
        (play_points * 0.25).to_i
      when "2-3", "2-4"
        (play_points * 0.5).to_i
      else
        (play_points * 0.75).to_i
      end

    elsif any_player_resigned?
      play_points = case "#{game_details["RoundNumber"]}-#{game_details["TurnNumber"]}"
      when "1-1", "1-2", "1-3"
        (play_points * 0.25).to_i
      when "1-4", "2-1", "2-2"
        (play_points * 0.5).to_i
      when "2-3", "2-4"
        (play_points * 0.75).to_i
      else
        play_points
      end
    end

    set_detailed_xp(:play, 1, play_points)

    play_points
  end

  def get_win_points game_player
    win_points = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:win]).achievement_value

    # for PVE we don't get here
    if any_player_resigned? && game_details["RoundNumber"] == 1
      win_points = (win_points * 0.5).to_i
    end

    set_detailed_xp(:win, 1, win_points)

    win_points
  end

  def get_misc_points game_player
    misc_points = 0

    if game_player["GoalsScored"] >= 5
      goals_scored_value = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:score_five]).achievement_value

      set_detailed_xp(:goals_scored, game_player["GoalsScored"], goals_scored_value)

      misc_points += goals_scored_value
    end

    if game_player["GoalsConceded"] == 0
      clean_sheet_value = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:clean_sheet]).achievement_value

      set_detailed_xp(:clean_sheet, 1, clean_sheet_value)

      misc_points += clean_sheet_value
    end

    if game_player["Hattricks"] > 0
      hattrick_value = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:hattrick]).achievement_value

      set_detailed_xp(:hattrick, game_player["Hattricks"], hattrick_value)

      misc_points += hattrick_value
    end

    if won_game(game_player["Outcome"]) && game_player["DeckPower"] < deck_powers.max
      underdog_value = RewardsConfig.find_by(achievement_type: RewardsConfig::ACHIEVEMENT_TYPES[:underdog]).achievement_value

      set_detailed_xp(:underdog, 1, underdog_value)

      misc_points += underdog_value
    end

    misc_points
  end

  # Claims the reward
  #
  # @note there is a safeguard for idempotency purposes (if delivered, do nothing)
  #
  # @params reward <Rewards::Reward> The reward associated with this player/game
  #
  def claim_reward reward
    return if reward.state == "delivered"

    reward.state_event = "claim"
    reward.save
  end

  def set_detailed_xp type, amount, xp_points
    @xp_points_detailed[type] = {amount: amount, xp_points: xp_points}
  end
end
