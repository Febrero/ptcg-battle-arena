module V1
  class GameModeSerializer < ActiveModel::Serializer
    attributes :uid,
      :name,
      :total_prize_pool,
      :prize_pool_winner_share,
      :prize_pool_realfevr_share,
      :compatible_ticket_ids,
      :active,
      :background_image_url,
      :erc20,
      :erc20_name,
      :card_image_url,
      :layout_colors,
      :ticket_factory_contract_address,
      :ticket_locker_and_distribution_contract_address,
      :game_mode,
      :winner_percentage,
      :rf_percentage,
      :burn_percentage,
      :possible_cashback_percentage,
      :winner_share,
      :rf_share,
      :burn_share,
      :possible_cashback_share,
      :ticket_amount_needed,
      :erc20_image_url,
      :entry_price_image_url,
      :rewards_multiplier,
      :admin,
      :admin_only,
      :partner_config,
      :home_highlight,
      :home_highlight_image_url,
      :home_highlight_image_mobile_url,
      :min_xp_level,
      :max_xp_level

    def partner_config
      GameModePartnerConfigSerializer.new(object.partner_config).serializable_hash if object.partner_config
    end

    def game_mode
      object._type
    end

    def erc20_name
      object.erc20_name_alt || object.erc20_name
    end

    def erc20_image_url
      object.erc20_image_url_alt || object.token["image_url"]
    end

    def erc20
      object.token["address"]
    end
  end
end
