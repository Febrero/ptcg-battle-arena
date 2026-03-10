class UserActivity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :wallet_addr, type: String
  field :event_info, type: Hash
  field :event_date, type: Time
  field :rewards_status, type: String
  field :season_uid, type: Integer

  belongs_to :source, polymorphic: true, primary_key: "uid"

  embeds_many :rewards, class_name: "UserActivities::Reward"

  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
  index({rewards_status: 1}, {name: "rewards_status_index", background: true})
  index({season_uid: 1}, {name: "season_uid_index", background: true})
  index({event_info: 1}, {name: "event_info_index", background: true})
  index({event_date: 1}, {name: "event_date_index", background: true})
  index({created_at: 1}, {name: "created_at_index", background: true})

  def update_rewards_status
    all_status = rewards.distinct(:status)

    result_status = if all_status.include?("canceled")
      "canceled"
    elsif all_status.include?("pending")
      "pending"
    else
      "completed"
    end

    update(rewards_status: result_status) if rewards_status != result_status
  end
end
