module V1
  class SurvivalSerializer < GameModeSerializer
    attributes :uid,
      :name,
      :total_prize_pool,
      :prize_pool_winner_share,
      :prize_pool_realfevr_share,
      :compatible_ticket_ids,
      :active,
      :background_image_url,
      :erc20_name,
      :start_date,
      :end_date,
      :state,
      :min_deck_tier,
      :max_deck_tier,
      :acceptance_rules,
      :levels_count,
      :game_mode,
      :survival_stages

    def survival_stages
      object.stages.map { |e| e.attributes.except("_id") }
    end

    def game_mode
      object._type
    end
  end
end
