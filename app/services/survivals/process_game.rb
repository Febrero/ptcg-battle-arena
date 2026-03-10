module Survivals
  class ProcessGame < ApplicationService
    def call game, game_details
      Rails.logger.info "Custom processing for survival\n\tgame: #{game.game_id}\n\tsurvival: #{game.game_mode_id}"

      survival = game.game_mode

      game.players.each do |player|
        survival_player = SurvivalPlayer.where(wallet_addr: player.wallet_addr, survival_id: game.game_mode_id).first

        raise Survivals::GameAlreadyProcessed.new(player.wallet_addr, survival.uid, game.game_id) if survival_player.games_on_survival.include?(game.game_id)

        should_finish_streak = false

        # set the ticket when he plays the first time in current streak
        if survival_player.active_entry.levels_completed == 0

          game_details["Players"].map! do |game_player|
            if game_player["WalletAddr"] == player.wallet_addr
              game_player["EntryCount"] = 1
            end
            game_player
          end
        end

        if player.winner?
          survival_player.update_current_streak_level(game.game_id)

          should_finish_streak = true	if survival_player.active_entry.levels_completed >= survival.levels_count || survival.closed?
        else
          should_finish_streak = true
        end

        Rails.logger.info "Should finish streak for player #{player.wallet_addr}? #{should_finish_streak}"

        if should_finish_streak
          survival_player.finish_streak(game.game_id)
        end
      end
    rescue Survivals::GameAlreadyProcessed => e
      Airbrake.notify(e)
    rescue => e
      Rails.logger.info "ERROR WHILE PROCESSING THE GAME: #{e.message}"
      Rails.logger.info e.backtrace.join("\n")

      raise e
    end
  end
end
