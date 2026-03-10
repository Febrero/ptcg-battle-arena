class OpenerEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process a opener event (Sidekiq Job)"

    Events::SmartContracts::Opener::Process.call(json_data)
  end
end
