module Survivals
  class GameAlreadyProcessed < StandardError
    def initialize(wallet_addr, survival_id, game_id)
      @wallet_addr = wallet_addr
      @survival_id = survival_id
      @game_id = game_id
    end

    def to_s
      "The game #{@game_id} was already processed for wallet: #{@wallet_addr} and survival_id: #{@survival_id}"
    end
  end
end
