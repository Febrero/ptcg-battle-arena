module V1
  class PrizeConfigsSerializer < ActiveModel::Serializer
    attributes :uid,
      :name,
      :active,
      :config

    def config
      object.config.to_h
    end
  end
end
