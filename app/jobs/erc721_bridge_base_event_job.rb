class Erc721BridgeBaseEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a erc721 base event (Sidekiq Job)"

    Events::SmartContracts::Bridge::Erc721Base::Process.call(json_data)
  end
end
