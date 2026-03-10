require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Rewards::Survival do
  let!(:survival_player) { create(:survival_player, wallet_addr: "0x123") }
  let!(:game) { create(:game, :survival) }
  let!(:survival) { create(:survival) }
  let!(:user_activity_survival) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {entry_id: survival_player.current_entry.id.to_s},
      source: survival_player.survival
    )
  end

  let!(:reward_event) do
    {
      "key" => "blabla",
      "final_value" => 1,
      "state" => "available",
      "reward_type" => "nft",
      "reward_subtype" => "special",
      "game_id" => game.game_id,
      "arena" => 1,
      "event_type" => "Arena",
      "wallet_addr" => "0x123"
    }
  end

  let!(:reward_update_event) do
    {
      "key" => "blabla",
      "final_value" => 1,
      "state" => "approved",
      "reward_type" => "nft",
      "reward_subtype" => "special",
      "game_id" => game.game_id,
      "arena" => 1,
      "event_type" => "Arena",
      "wallet_addr" => "0x123"
    }
  end

  describe "handles reward creation" do
    it "creates a reward" do
      survival_player.current_entry.update(games_ids: [game.game_id])
      described_class.new(reward_event).handle

      expect(user_activity_survival.reload.rewards.size).to eq(1)
      expect(user_activity_survival.reload.rewards_status).to eq("pending")
    end
  end

  describe "handles reward update" do
    it "creates a reward" do
      survival_player.current_entry.update(games_ids: [game.game_id])
      described_class.new(reward_event).handle # creates
      described_class.new(reward_update_event).handle # updates

      expect(user_activity_survival.reload.rewards.size).to eq(1)
      expect(user_activity_survival.reload.rewards.first.status).to eq("pending")
    end
  end
end
