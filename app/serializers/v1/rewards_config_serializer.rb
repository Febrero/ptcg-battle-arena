module V1
  class RewardsConfigSerializer < ActiveModel::Serializer
    attributes :achievement_type, :achievement_value, :desc
  end
end
