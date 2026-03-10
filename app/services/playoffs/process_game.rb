module Playoffs
  class ProcessGame < ApplicationService
    attr_accessor :playoff, :game, :game_details, :winner_team, :current_bracket, :next_bracket

    def call game, game_details
      Rails.logger.info "Custom processing for Playoff GAME: #{game.game_id}\n\Playoff: #{game.game_mode_id} Bracket: #{game_details["CurrentBracketId"]}"

      @game = game
      @game_details = game_details
      @playoff = Playoff.where(uid: game.game_mode_id).first
      raise "Playoff doesn't exist" if !playoff

      @current_bracket = get_current_bracket
      @winner_team = get_winner_team

      current_bracket.teams.each do |team|
        if team.wallet_addr_downcased != winner_team.wallet_addr_downcased
          team.finish_playoff(current_bracket.round, playoff.prize_amount_by_round(current_bracket.round - 1))
        end
      end

      @next_bracket = get_next_bracket

      update_game_bracket_info

      Playoffs::Notificator.call(
        playoff.uid,
        Playoffs::Notificator::TYPE_PROCESS_GAME,
        {
          current_bracket: current_bracket.current_bracket,
          winner_team_id: winner_team.id.to_s,
          winner_team_wallet: winner_team.wallet_addr_downcased,
          game_id: game.game_id
        }
      )

      if !current_bracket.winner_selected_by_system
        if next_bracket.present?
          update_next_bracket_info
        else
          current_bracket.teams.each do |team|
            if team.wallet_addr_downcased == winner_team.wallet_addr_downcased
              team.finish_playoff(current_bracket.round, playoff.prize_amount_by_round(current_bracket.round))
            end
          end

          Playoffs::Finalize.call(playoff.uid, winner_team.id.to_s)
        end
      end

      # PlayoffCount will be send it in the end of the playoff
      # game_details["Players"].map! do |game_player|
      #   team = get_team_from_wallet game_player["WalletAddr"]
      #   if current_bracket.round == 1 || (current_bracket.round == 2 && playoff.brackets.where(round: 1, teams_ids: team.id).first&.teams_ids&.include?(nil)) # first game in playoff or second if first one was an bye slot
      #     game_player["PlayoffCount"] = 1
      #   end
      #   game_player
      # end
    end

    private

    # Get the playoff team that won the game
    #
    def get_winner_team
      get_team_from_wallet game.winner
    end

    def get_team_from_wallet wallet
      playoff.teams.where(wallet_addr_downcased: wallet.downcase).first
    end

    # Get current bracket based on the game_details info
    #
    def get_current_bracket
      playoff.brackets.where(id: game_details["CurrentBracketId"]).first
    end

    # Get next bracket based on the current one
    #
    def get_next_bracket
      playoff.brackets.where(current_bracket: current_bracket.next_bracket).first
    end

    # Denormalize game info for the current bracket

    def update_game_bracket_info
      current_bracket
        .update_attributes(
          winner_team_id: winner_team.id.to_s,
          game_id: game.game_id,
          goals_scored: goals_scored,
          game_end_reason: game.game_end_reason
        )
    end

    # Denormalize game info for the current bracket
    #
    def update_next_bracket_info
      # next_bracket.teams_ids << winner_team.id.to_s
      winner_team.current_bracket_id = next_bracket.id.to_s
      winner_team.save

      next_bracket.teams_ids[next_bracket.previous_brackets.find_index(current_bracket.current_bracket)] = winner_team.id.to_s
      next_bracket.save!
    end

    def goals_scored
      scored = {}

      game_details["Players"].each do |player_details|
        scored[player_details["WalletAddr"].downcase] = player_details["GoalsScored"]
      end

      current_bracket.teams_ids&.map do |team_id|
        if team_id
          team = Playoffs::Team.find(team_id)
          scored[team.wallet_addr_downcased]
        end
      end
    end
  end
end
