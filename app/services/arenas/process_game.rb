module Arenas
  class ProcessGame < ApplicationService
    def call game, game_details
      Rails.logger.info "Custom processing for arena game: #{game.id}\n\tarena: #{game.game_mode_id}"

      Arenas::CalculatePrizeValue.call(game, game_details, game.winner)

      if game_details["MatchType"] == "Arena"
        game.players.each do |player|
          Arenas::GeneratePrize.call(game.game_mode, player, game.game_id)
        end
      end
    end
  end
end
