module Playoffs
  class AdvanceRoundJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform playoff_uid
      Rails.logger.info "Going to advance round for a playoff (Sidekiq Job)"

      Playoffs::AdvanceRound.call(playoff_uid, true)
    end
  end
end
