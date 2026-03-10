module Playoffs
  class ContinueJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform playoff_uid
      Rails.logger.info "Going to continue event"
      Playoffs::Continue.call(playoff_uid, true)
    end
  end
end
