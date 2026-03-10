module Arenas
  class CalculatePrizeValue < ::CalculateGamePlayerPrize
    # @implementation Implement for getting the prize info from the game_mode
    #
    def get_prize_info
      prize_amount = game_mode.try(:prize_pool_winner_share) || 0
      prize_type = game_mode.try(:erc20_name) || "FEVR"

      [prize_amount, prize_type]
    end
  end
end
