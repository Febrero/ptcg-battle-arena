require "rails_helper"

RSpec.describe SurvivalPlayer, type: :model do
  let!(:season) { create(:season) }
  let(:survival) {
    create(:survival, uid: 1)
  }
  let(:game) {
    create(:game, game_mode_id: 1)
  }

  describe "indexes" do
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "survival_player_wallet_addr_index", background: true) }
    it { is_expected.to have_index_for(active_entry_id: 1).with_options(name: "survival_player_active_entry_id_index", background: true) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:survival).with_foreign_key(:survival_id) }
    it { is_expected.to embed_many(:entries) }
  end

  describe "streak actions" do
    let(:survival_player) {
      player = create(:survival_player, entries: [], survival: survival)
      create(:game_player, game: game, wallet_addr: player.wallet_addr)
      player
    }
    let(:ticket_id) { 12345 }

    context "when beggining a streak" do
      it "generates an entry" do
        expect {
          survival_player.begin_streak(ticket_id)
        }.to change {
          survival_player.entries.count
        }.by(1)
      end

      it "generates an entry with the ticket_id given" do
        survival_player.begin_streak(ticket_id)

        active_entry = survival_player.entries.detect { |e| !e.closed? }

        expect(active_entry.ticket_id).to eq(ticket_id)
      end

      it "marks the active_entry_id with the new entry id" do
        survival_player.begin_streak(ticket_id)

        active_entry = survival_player.entries.detect { |e| !e.closed? }

        expect(survival_player.active_entry_id).to eq(active_entry.id.to_s)
      end

      it "raises and error if another entry is active" do
        survival_player.begin_streak(ticket_id)

        expect { survival_player.begin_streak(ticket_id) }.to raise_error(Survivals::MultipleActiveStreak)
      end
    end

    context "when updating a streak level" do
      it "increments the levels_completed on the active entry only" do
        player = create(:survival_player)

        player.begin_streak(ticket_id)

        expect {
          player.update_current_streak_level(game.game_id)
        }.to change {
          player.active_entry.levels_completed
        }.by(1)
      end

      it "does not increment the levels_completed on non active entries" do
        player = create(:survival_player)

        player.begin_streak(ticket_id)

        expect {
          player.update_current_streak_level(game.game_id)
        }.not_to change {
          player.entries.ne(id: player.active_entry_id).all.map(&:levels_completed)
        }
      end

      it "persists the game_id on the games_ids array" do
        player = create(:survival_player)

        player.begin_streak(ticket_id)

        expect {
          player.update_current_streak_level(game.game_id)
        }.to change {
          player.active_entry.games_ids.count
        }.by(1)
      end
    end

    context "when finishing a streak" do
      before do
        allow(Survivals::SendStreakEventToKafka).to receive(:call)
        allow(Survivals::GeneratePrize).to receive(:call)
      end

      it "removeds the active_entry_id" do
        survival_player.begin_streak(ticket_id)
        expect {
          survival_player.finish_streak(game.game_id)
        }.to change {
          survival_player.active_entry_id
        }.from(String).to(nil)
      end

      it "sets the closed flag on the entry" do
        survival_player.begin_streak(ticket_id)

        entry = survival_player.active_entry

        expect {
          survival_player.finish_streak(game.game_id)
        }.to change {
          entry.closed
        }.from(false).to(true)
      end

      it "sets the closed date on the entry" do
        survival_player.begin_streak(ticket_id)

        entry = survival_player.active_entry

        expect {
          survival_player.finish_streak(game.game_id)
        }.to change {
          entry.closed_at
        }.from(nil).to(DateTime)
      end

      it "persists the game_id on the games_ids array" do
        survival_player.begin_streak(ticket_id)

        expect {
          survival_player.finish_streak(game.game_id)
        }.to change {
          survival_player.entries.last.games_ids.count
        }.by(1)
      end

      it "creates a user activity" do
        survival_player.begin_streak(ticket_id)

        entry_id = survival_player.active_entry_id

        survival_player.finish_streak(game.game_id)

        expect(UserActivity.where("event_info.entry_id": entry_id).count).to eq(1)
      end
    end
  end

  it "returns the current active entry" do
    player = create(:survival_player)

    entry = player.begin_streak(12345)

    expect(player.active_entry).to eq(entry)
  end

  it "does not return any entry if none exists" do
    player = create(:survival_player, entries: [])

    expect(player.active_entry).to be_nil
  end

  it "returns a current entry if exist" do
    allow(Survivals::SendStreakEventToKafka).to receive(:call)
    allow(Survivals::GeneratePrize).to receive(:call)

    survival = create(:survival, uid: 1)
    game = create(:game, game_mode_id: 1)
    player = create(:survival_player, entries: [], survival: survival)
    create(:game_player, game: game, wallet_addr: player.wallet_addr)

    player.begin_streak(12345)
    player.finish_streak(game.game_id)
    player.begin_streak(67890)
    player.update_current_streak_level(game.game_id)

    expect(player.current_entry).to eq(player.entries.last)
  end

  it "raises error if no entry exists" do
    player = create(:survival_player, entries: [])

    expect { player.current_entry }.to raise_error(Survivals::EntryNotFound)
  end
end
