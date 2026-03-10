class NftsStatsEventJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform json_data
    Rails.logger.info "Going to process Nfts Stats (Sidekiq Job)"

    Events::NftsStats::Process.call(json_data)
  end
end
