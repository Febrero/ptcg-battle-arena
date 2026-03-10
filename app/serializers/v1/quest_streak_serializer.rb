module V1
  class QuestStreakSerializer < ActiveModel::Serializer
    attributes :id,
      :count,
      :profile_id,
      :claims,
      :end_date,
      :wallet_addr

    def id
      object.id.to_s
    end

    def profile_id
      object.profile.id.to_s
    end

    def wallet_addr
      object.profile.wallet_addr
    end
  end
end
