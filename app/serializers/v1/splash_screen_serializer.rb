module V1
  class SplashScreenSerializer < ActiveModel::Serializer
    attributes :name, :image_url, :active
  end
end
