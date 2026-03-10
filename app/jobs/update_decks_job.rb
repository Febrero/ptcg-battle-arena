class UpdateDecksJob < ApplicationJob
  sidekiq_options retry: 0, queue: :default, backtrace: true

  def perform
    Rails.logger.info "Going to update all decks (Sidekiq Job)"

    UpdateDecks.call
  end
end
