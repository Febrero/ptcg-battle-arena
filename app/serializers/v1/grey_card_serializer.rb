module V1
  class GreyCardSerializer < ActiveModel::Serializer
    attributes :uid,
      :rarity,
      :player_name,
      :drop,
      :drop_slug,
      :position,
      :defense,
      :attack,
      :stamina,
      :ball_stopper,
      :super_sub,
      :man_mark,
      :enforcer,
      :inspire,
      :captain,
      :long_passer,
      :box_to_box,
      :dribbler,
      :power,
      :enabler, # todo temp fix
      :energizer # todo temp fix

    def enabler
      object.inspire
    end

    def energizer
      object.captain
    end
  end
end
