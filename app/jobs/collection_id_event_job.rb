class CollectionIdEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a collection id event (Sidekiq Job)"

    Events::SmartContracts::CollectionId::Process.call(json_data)
  end
end
