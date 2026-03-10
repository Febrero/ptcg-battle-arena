module V1
  class QuestConfigSerializer < ActiveModel::Serializer
    attributes :uid, :type, :active, :stages

    def stages
      object.serializer
    end
  end
end
