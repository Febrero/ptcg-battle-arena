class CloseStreaksJob < ApplicationJob
  sidekiq_options retry: 0, queue: :cron, backtrace: true

  def perform(days_since_last_game)
    CloseStreaksService
      .call(days_since_last_game)
  end
end
