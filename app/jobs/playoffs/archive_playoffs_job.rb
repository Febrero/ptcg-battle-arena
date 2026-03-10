module Playoffs
  class ArchivePlayoffsJob < ApplicationJob
    sidekiq_options retry: 0, queue: :cron, backtrace: true

    def perform
      Playoffs::ArchivePlayoffs.call
    end
  end
end
