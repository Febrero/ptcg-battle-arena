class TicketFactoryEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a ticket factory event (Sidekiq Job)"

    Events::SmartContracts::TicketFactory::Process.call(json_data)
  end
end
