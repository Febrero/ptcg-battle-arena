module Callbacks
  module GameModeCallbacks
    def before_validation(game_mode)
      if game_mode.max_xp_level.present? || game_mode.min_xp_level.present?
        game_mode.min_xp_level = game_mode.min_xp_level.to_i
        game_mode.max_xp_level = game_mode.max_xp_level.to_i
      end
    end

    def before_create(game_mode)
      game_mode.uid = (GameMode.max(:uid) || 0) + 1

      if (!game_mode.respond_to? :has_custom_prize) || !game_mode.has_custom_prize
        game_mode.prize_pool_winner_share = game_mode.calc_prize_pool_winner_share
        game_mode.prize_pool_realfevr_share = game_mode.calc_prize_pool_realfevr_share
        game_mode.prize_pool_possible_cashback_share = game_mode.calc_prize_pool_possible_cashback_share
      end
    end

    def before_update(game_mode)
      if (game_mode.changes.has_key? :total_prize_pool) && ((!game_mode.respond_to? :has_custom_prize) || !game_mode.has_custom_prize)
        game_mode.prize_pool_winner_share = game_mode.calc_prize_pool_winner_share
        game_mode.prize_pool_realfevr_share = game_mode.calc_prize_pool_realfevr_share
        game_mode.prize_pool_possible_cashback_share = game_mode.calc_prize_pool_possible_cashback_share
      end
    end
  end
end

# GameMode.batch_size(500).each do |gm|
#   if !gm.rf_percentage && !gm.burn_percentage
#     gm.rf_percentage = 4.0
#     gm.burn_percentage = 1.0
#     gm.possible_chashback_percentage = 5.0
#     gm.save
#   end
# end
