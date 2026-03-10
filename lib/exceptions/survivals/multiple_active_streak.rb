module Survivals
  class MultipleActiveStreak < StandardError
    def initialize(wallet_addr, survival_id)
      @wallet_addr = wallet_addr
      @survival_id = survival_id
    end

    def to_s
      "A player cannot have more than one streak open for a given survival.\n\twallet: #{@wallet_addr}\n\tsurvival_id: #{@survival_id}"
    end
  end
end
