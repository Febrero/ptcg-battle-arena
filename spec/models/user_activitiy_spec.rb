require "rails_helper"

RSpec.describe UserActivity, type: :model do
  subject(:user_activity) { described_class.new }

  describe "indexes" do
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "wallet_addr_index", background: true) }
    it { is_expected.to have_index_for(event_info: 1).with_options(name: "event_info_index", background: true) }
    it { is_expected.to have_index_for(event_date: 1).with_options(name: "event_date_index", background: true) }
    it { is_expected.to have_index_for(created_at: 1).with_options(name: "created_at_index", background: true) }
  end

  describe "update_rewards_status method" do
    let!(:quest_profile) { create(:quest_profile) }
    let!(:user_activity_quest) do
      create(
        :user_activity,
        wallet_addr: "0x123",
        event_info: {day: quest_profile.count},
        source: quest_profile.quest
      )
    end
    let!(:reward) { create(:reward, :prizes, status: "completed", reward_type: "fevr", user_activity: user_activity_quest) }

    it "calculates the rewards pending status" do
      reward.update(status: "pending")

      user_activity_quest.update_rewards_status

      expect(user_activity_quest.rewards_status).to eq("pending")
    end

    it "calculates the rewards canceled status" do
      reward.update(status: "canceled")

      user_activity_quest.update_rewards_status

      expect(user_activity_quest.rewards_status).to eq("canceled")
    end

    it "calculates the rewards canceled status" do
      reward.update(status: "processed")

      user_activity_quest.update_rewards_status

      expect(user_activity_quest.rewards_status).to eq("completed")
    end
  end
end
