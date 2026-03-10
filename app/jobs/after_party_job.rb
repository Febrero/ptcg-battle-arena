class AfterPartyJob < ApplicationJob
  sidekiq_options retry: 0, queue: :default, backtrace: true

  def perform(service)
    Rails.logger.info "Going to AfterParty Code"
    service
      .constantize
      .new
      .call
  end
end
