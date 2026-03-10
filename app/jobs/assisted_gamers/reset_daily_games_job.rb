module AssistedGamers
  class ResetDailyGamesJob < ApplicationJob
    sidekiq_options retry: 3, queue: :cron, backtrace: true

    def perform
      AssistedGamers::ResetDailyGames.call
    end
  end
end
