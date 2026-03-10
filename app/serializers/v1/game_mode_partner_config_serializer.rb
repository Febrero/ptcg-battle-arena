module V1
  class GameModePartnerConfigSerializer < ActiveModel::Serializer
    attributes :uid,
      :name,
      :custom_maps_settings
  end
end
