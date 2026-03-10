module Survivals
  class FinishPlayersStreaks < ApplicationService
    def call survival_players_ids
      Rails.logger.info "Going to finish players streaks"

      SurvivalPlayer.in(id: survival_players_ids).each do |survival_player|
        Rails.logger.info "should finish streak for survival player: #{survival_player.id}"

        survival_player.finish_streak
      end
    end
  end
end
