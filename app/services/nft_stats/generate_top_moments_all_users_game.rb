module NftStats
  class GenerateTopMomentsAllUsersGame
    include Callable
    attr_reader :batch_size
    def initialize(batch_size = 1000)
      @batch_size = batch_size
    end

    def call
      distinct_wallet_addrs = Set.new

      # Fetch the next batch of distinct wallet_addr values
      GamePlayer.all.batch_size(batch_size).each do |game_player|
        next if game_player.wallet_addr.blank?
        distinct_wallet_addrs << game_player.wallet_addr
      end

      distinct_wallet_addrs.each do |wallet|
        GenerateTopMomentsJob.perform_async(wallet)
      end
      distinct_wallet_addrs.count
    end
  end
end
