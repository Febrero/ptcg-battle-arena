require "rails_helper"

RSpec.describe Game, type: :model do
  subject { described_class.new }

  describe "Validations" do
    it "indexes" do
      expect(subject).to have_index_for(game_id: 1).with_options(unique: true, background: true)
      expect(subject).to have_index_for(game_start_time: 1).with_options(background: true)
      expect(subject).to have_index_for(game_mode_id: 1).with_options(background: true)
    end

    it { is_expected.to validate_presence_of(:game_id) }
    it { is_expected.to validate_presence_of(:game_log_id) }
    it { is_expected.to validate_presence_of(:game_start_time) }

    it { is_expected.to validate_uniqueness_of(:game_id) }
  end

  describe "generate game event" do
    let!(:game_event) { create(:game) }

    it "generates and event with two players" do
      create_list(:game_player, 2, game: game_event)
      expect(game_event.players.count).to eq(2)
    end

    it "the game id should be unique" do
      expect do
        create(:game, game_id: game_event.game_id)
      end.to raise_exception(Mongoid::Errors::Validations)
    end

    it "generates a game with an arena FK set" do
      expect(build(:game).valid?).to be_truthy
    end

    it "generates a game without an game_mode FK set" do
      expect(build(:game, game_mode_id: nil).valid?).to be_truthy
    end
  end

  describe "recriate the original request" do
    let!(:game_event) { create(:game) }

    it "has all keys camelcased" do
      expect(game_event.to_original_request.keys.none? { |k| k.match(/([_-]|\s)/) }).to be_truthy
    end

    it "maps GameId to the game_id" do
      expect(game_event.to_original_request["GameId"]).to eq(game_event.game_id)
    end

    it "maps GameMode to the game_mode class" do
      game = create(:game, :arena)

      expect(game.to_original_request["GameMode"]).to eq(game.game_mode._type)
    end

    it "maps GameMode to Arena if game_mode class doesn't exist" do
      game = create(:game, :pve)

      expect(game.to_original_request["GameMode"]).to eq("Arena")
    end

    it "has an array of players" do
      expect(game_event.to_original_request["Players"]).to be_a(Array)
    end

    it "maps the players fields" do
      req_players_wallets = game_event.to_original_request["Players"].map { |p| p["WalletAddress"] }
      db_players_wallets = game_event.players.map(&:wallet_addr)

      expect(req_players_wallets).to match_array(db_players_wallets)
    end
  end

  describe "match counts" do
    before do
      create(:game, :pve, game_mode_id: -2)
      create(:game, :pvp, game_mode_id: -1)
      create(:game, :arena)
    end

    let!(:miami) { create(:game, match_type: "Arena") }

    it "returns pve count" do
      expect(described_class.match_count("PVE", -2)).to eq(1)
    end

    it "returns pvp count" do
      expect(described_class.match_count("PVP", -1)).to eq(1)
    end

    it "returns specific arena count" do
      expect(described_class.match_count("Arena", miami.game_mode_id)).to eq(1)
    end
  end
end
