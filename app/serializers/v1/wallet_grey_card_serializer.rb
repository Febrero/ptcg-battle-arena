module V1
  class WalletGreyCardSerializer < ActiveModel::Serializer
    attributes :wallet_addr,
      :rarity,
      :player_name,
      :drop,
      :drop_slug,
      :position,
      :defense,
      :attack,
      :stamina,
      :ball_stopper,
      :inspire,
      :captain,
      :long_passer,
      :box_to_box,
      :dribbler,
      :super_sub,
      :man_mark,
      :enforcer,
      :power,
      :grey_card_id
  end
end
