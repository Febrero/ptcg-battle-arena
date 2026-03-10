module Playoffs
  class OpenPlayoffJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform
      Rails.logger.info "Going to process service for opening upcoming playoffs (Sidekiq Job)"

      Playoffs::OpenPlayoff.call
    end
  end
end
