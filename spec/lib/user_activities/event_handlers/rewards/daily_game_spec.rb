require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Rewards::DailyGame do
  let!(:quest_streak) { create(:quest_streak) }
  let!(:user_activity_quest) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {day: quest_streak.count, quest_streak_id: quest_streak.id.to_s},
      source: quest_streak.profile.quest
    )
  end

  let!(:reward_event) do
    {
      "key" => "blabla",
      "final_value" => 1,
      "state" => "available",
      "reward_type" => "fevr",
      "reward_subtype" => nil,
      "arena" => 1,
      "event_type" => "DailyGame",
      "event_detail" => {"day_quest" => quest_streak.count, "quest_streak_id" => quest_streak.id.to_s},
      "wallet_addr" => "0x123"
    }
  end

  let!(:reward_update_event) do
    {
      "key" => "blabla",
      "final_value" => 1,
      "state" => "approved",
      "reward_type" => "ticket",
      "reward_subtype" => "lisbon",
      "arena" => 1,
      "event_type" => "DailyGame",
      "event_detail" => {"day_quest" => quest_streak.count, "quest_streak_id" => quest_streak.id.to_s},
      "wallet_addr" => "0x123"
    }
  end

  describe "handles reward creation" do
    it "creates a reward" do
      described_class.new(reward_event).handle

      expect(user_activity_quest.reload.rewards.size).to eq(1)
      expect(user_activity_quest.reload.rewards_status).to eq("pending")
    end
  end

  describe "handles reward update" do
    it "creates a reward" do
      described_class.new(reward_event).handle # creates
      described_class.new(reward_update_event).handle # updates

      expect(user_activity_quest.reload.rewards.size).to eq(1)
      expect(user_activity_quest.reload.rewards.first.status).to eq("pending")
    end
  end
end
