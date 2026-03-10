module Playoffs
  class CalculatePrizePoolJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform playoff_uid, save = true
      Rails.logger.info "Playoff prize pool"
      playoff = Playoff.find_by(uid: playoff_uid)
      ::Playoffs::CalculatePrizePool.call(playoff, save)
    end
  end
end
