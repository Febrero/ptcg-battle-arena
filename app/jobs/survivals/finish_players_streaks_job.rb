module Survivals
  class FinishPlayersStreaksJob < ApplicationJob
    sidekiq_options retry: 0, queue: :survival, backtrace: true

    def perform survival_players_ids
      Rails.logger.info "Going to process service for finishing streaks for survival players (Sidekiq Job)"

      Survivals::FinishPlayersStreaks.call(survival_players_ids)
    end
  end
end
