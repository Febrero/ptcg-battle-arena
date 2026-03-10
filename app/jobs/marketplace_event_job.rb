class MarketplaceEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a marketplace event (Sidekiq Job)"

    Events::SmartContracts::Marketplace::Process.call(json_data)
  end
end
