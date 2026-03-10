class MarketplaceV2EventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a marketplace v2 event (Sidekiq Job)"

    Events::SmartContracts::MarketplaceV2::Process.call(json_data)
  end
end
