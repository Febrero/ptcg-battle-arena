module Playoffs
  class StartPlayoffJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform playoff_uid
      Rails.logger.info "Going to process service for starting playoff ##{playoff_uid} (Sidekiq Job)"
      $stdout.flush
      Playoffs::StartPlayoff.call(playoff_uid)
    end
  end
end
