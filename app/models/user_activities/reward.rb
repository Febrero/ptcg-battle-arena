module UserActivities
  class Reward
    include Mongoid::Document
    include Mongoid::Timestamps

    field :status, type: String
    field :source, type: String
    field :source_key, type: String
    field :reward_type, type: String
    field :reward_subtype, type: String
    field :value, type: Float
    field :offer_detail, type: Hash
    field :delivered_at, type: Time

    embedded_in :user_activity, class_name: "UserActivity"
  end
end
