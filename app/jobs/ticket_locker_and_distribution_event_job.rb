class TicketLockerAndDistributionEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a ticket locker and distribution event (Sidekiq Job)"

    Events::SmartContracts::TicketLockerAndDistribution::Process.call(json_data)
  end
end
