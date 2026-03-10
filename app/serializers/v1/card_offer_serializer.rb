module V1
  class CardOfferSerializer < ActiveModel::Serializer
    attributes :wallet_addr,
      :quantity,
      :card_type,
      :offer_detail,
      :reward_key,
      :source,
      :delivered,
      :delivered_at
  end
end
