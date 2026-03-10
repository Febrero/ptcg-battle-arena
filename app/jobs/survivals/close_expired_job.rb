module Survivals
  class CloseExpiredJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform
      Rails.logger.info "Going to process service for closing expired survivals (Sidekiq Job)"

      Survivals::CloseExpired.call
    end
  end
end
