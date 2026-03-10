module Playoffs
  class GeneratePlayoffBracketsJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform playoff_uid
      Rails.logger.info "Going to generate brackets (Sidekiq Job)"

      Playoffs::GenerateBrackets.call playoff_uid
    end
  end
end
