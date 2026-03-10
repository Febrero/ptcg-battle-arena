require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Prizes::Arena do
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

  let!(:prize_event) do
    {
      "id" => "123",
      "created_at" => Time.now.to_s,
      "state" => "available",
      "game_id" => game.game_id,
      "complex_game_id" => "xpto",
      "ticket_id" => game_player.ticket_id,
      "ticket_amount" => game_player.ticket_amount,
      "wallet_addr" => game_player.wallet_addr,
      "match_type" => "Arena",
      "game_mode" => "Arena",
      "game_mode_id" => 1,
      "survival_levels_completed" => nil,
      "survival_max_level" => nil,
      "erc20" => "0x123",
      "erc20_name" => "fevr",
      "deliver_tx_hash" => "0x123u1209031029312",
      "prize_awarded" => true
    }
  end

  let!(:prize_update_event) do
    {
      "id" => "123",
      "created_at" => Time.now.to_s,
      "state" => "processed",
      "game_id" => game.game_id,
      "complex_game_id" => "xpto",
      "ticket_id" => game_player.ticket_id,
      "ticket_amount" => game_player.ticket_amount,
      "wallet_addr" => game_player.wallet_addr,
      "match_type" => "Arena",
      "game_mode" => "Arena",
      "game_mode_id" => 1,
      "survival_levels_completed" => nil,
      "survival_max_level" => nil,
      "erc20" => "0x123",
      "erc20_name" => "fevr",
      "deliver_tx_hash" => "0x123u1209031029312",
      "prize_awarded" => true
    }
  end

  describe "handles reward creation" do
    it "creates a reward" do
      described_class.new(prize_event).handle

      expect(user_activity_game.reload.rewards.size).to eq(1)
      expect(user_activity_game.reload.rewards_status).to eq("pending")
    end
  end

  describe "handles reward update" do
    it "creates a reward" do
      described_class.new(prize_event).handle # creates
      described_class.new(prize_update_event).handle # updates

      expect(user_activity_game.reload.rewards.size).to eq(1)
      expect(user_activity_game.reload.rewards.first.status).to eq("completed")
    end
  end
end
