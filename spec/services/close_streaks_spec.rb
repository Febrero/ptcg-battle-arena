require "rails_helper"

RSpec.describe CloseStreaksService do
  describe ".call" do
    it "closes streaks for profiles with last game played more than 2 days ago" do
      create(:quest_profile, wallet_addr: "0x123", last_game_played: 3.days.ago)
      expect_any_instance_of(GameType::QuestProfile).to receive(:close_streak)
      described_class.call(2)
    end

    it "closes streaks for profiles with last game played more than 1 day ago" do
      create(:quest_profile, wallet_addr: "0x123", last_game_played: 3.days.ago)
      create(:quest_profile, wallet_addr: "0x456", last_game_played: 1.day.ago)
      receive_count = 0
      allow_any_instance_of(GameType::QuestProfile).to receive(:close_streak) { receive_count += 1 }
      described_class.call(1)
      expect(receive_count).to eq(2)
    end
  end
end
