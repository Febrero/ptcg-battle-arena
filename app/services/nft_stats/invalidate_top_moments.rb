module NftStats
  class InvalidateTopMoments
    include Callable

    def initialize(wallet_addr)
      @wallet_addr = wallet_addr.downcase
    end

    attr_reader :wallet_addr

    def call
      TopMoments::NftStats.update_ownership_last_updated_at(wallet_addr)
    end
  end
end
