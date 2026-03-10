require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Prizes::Survival do
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

  let!(:prize_event) do
    {
      "id" => "123",
      "created_at" => Time.now.to_s,
      "state" => "available",
      "game_id" => game.game_id,
      "complex_game_id" => "xpto",
      "ticket_id" => survival_player.current_entry.ticket_id,
      "ticket_amount" => survival_player.current_entry.ticket_amount,
      "wallet_addr" => survival_player.wallet_addr,
      "match_type" => "Survival",
      "game_mode" => "Survival",
      "game_mode_id" => survival.uid,
      "survival_levels_completed" => 5,
      "survival_max_level" => survival.levels_count,
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
      "ticket_id" => survival_player.current_entry.ticket_id,
      "ticket_amount" => survival_player.current_entry.ticket_amount,
      "wallet_addr" => survival_player.wallet_addr,
      "match_type" => "Survival",
      "game_mode" => "Survival",
      "game_mode_id" => survival.uid,
      "survival_levels_completed" => 5,
      "survival_max_level" => survival.levels_count,
      "erc20" => "0x123",
      "erc20_name" => "fevr",
      "deliver_tx_hash" => "0x123u1209031029312",
      "prize_awarded" => true
    }
  end

  describe "handles reward creation" do
    it "creates a reward" do
      survival_player.current_entry.update(games_ids: [game.game_id])
      described_class.new(prize_event).handle

      expect(user_activity_survival.reload.rewards.size).to eq(1)
      expect(user_activity_survival.reload.rewards_status).to eq("pending")
    end
  end

  describe "handles reward update" do
    it "creates a reward" do
      survival_player.current_entry.update(games_ids: [game.game_id])
      described_class.new(prize_event).handle # creates
      described_class.new(prize_update_event).handle # updates

      expect(user_activity_survival.reload.rewards.size).to eq(1)
      expect(user_activity_survival.reload.rewards.first.status).to eq("completed")
    end
  end
end
