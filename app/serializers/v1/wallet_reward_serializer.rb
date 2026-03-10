module V1
  class WalletRewardSerializer < ActiveModel::Serializer
    attributes :wallet_addr, :total_value, :reward_type, :event_type, :reward_subtype, :cards_detail, :xp_detail

    def total_value
      object["final_value"] || object["value"]
    end

    def wallet_addr
      object["wallet_addr"]
    end

    def reward_type
      object["reward_type"]
    end

    def event_type
      object["event_type"]
    end

    def reward_subtype
      object["reward_subtype"]
    end

    def xp_detail
      return [] if object["reward_type"] != "xp"

      xp_details = object["event_detail"]&.fetch("xp_detailed", {})

      return [] if xp_details.blank?

      xp_details.map { |k, v| {name: k.to_s.titleize, amount: v["amount"], xp_points: v["xp_points"]} }
    end

    # cards attributes
    def cards_detail
      (object["reward_type"] == "card") ? object["offer_detail"]["cards"] : {}
    end
  end
end
