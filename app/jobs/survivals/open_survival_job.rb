module Survivals
  class OpenSurvivalJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform
      Rails.logger.info "Going to process service for opening incoming survivals (Sidekiq Job)"

      Survivals::OpenSurvival.call
    end
  end
end
