class NftsStatsInvalidateTopMomentsJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform wallet_addr
    Rails.logger.info "Going to Generate Top Moments from recent nft_stats_uid persisted (Sidekiq Job)"

    NftStats::InvalidateTopMoments.call(wallet_addr)
  end
end
