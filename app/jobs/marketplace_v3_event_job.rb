class MarketplaceV3EventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a marketplace v3 event (Sidekiq Job)"

    Events::SmartContracts::MarketplaceV3::Process.call(json_data)
  end
end
