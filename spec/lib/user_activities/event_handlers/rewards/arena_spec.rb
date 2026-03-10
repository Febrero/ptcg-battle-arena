require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Rewards::Arena do
  let!(:game) {
    create(:game, :arena, players_wallet_addresses: [
      "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
      "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b"
    ])
  }
  let!(:game_player) { create(:game_player, game: game, wallet_addr: "0x123") }
  let!(:user_activity_game) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {game_id: game_player.game.game_id},
      source: game_player.game.game_mode
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
      described_class.new(reward_event).handle

      expect(user_activity_game.reload.rewards.size).to eq(1)
      expect(user_activity_game.reload.rewards_status).to eq("pending")
    end
  end

  describe "handles reward update" do
    it "creates a reward" do
      described_class.new(reward_event).handle # creates
      described_class.new(reward_update_event).handle # updates

      expect(user_activity_game.reload.rewards.size).to eq(1)
      expect(user_activity_game.reload.rewards.first.status).to eq("pending")
    end
  end
end
