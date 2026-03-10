class GenerateTopMomentsJob < ApplicationJob
  sidekiq_options retry: 0, queue: :events, backtrace: true

  def perform wallet_addr
    Rails.logger.info "Going to Generate Top Moments to #{wallet_addr}"

    NftStats::GenerateTopMoments.call(wallet_addr)
  end
end
