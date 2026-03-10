module Survivals
  class CalculatePrizeValue < ::CalculateGamePlayerPrize
    # @implementation Implement for getting the prize info from the game_mode
    #
    def get_prize_info
      survival_player = SurvivalPlayer.where(wallet_addr: game_player.wallet_addr, survival_id: game.game_mode_id).first

      prize_stage = game_mode.stages.where(level: survival_player.current_entry.levels_completed).first

      prize_amount = prize_stage.try(:prize_amount) || 0
      prize_type = prize_stage.try(:prize_type) || "FEVR"

      [prize_amount, prize_type]
    end
  end
end
