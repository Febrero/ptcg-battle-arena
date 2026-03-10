require "rails_helper"

RSpec.describe PlayerProfile::Stats::Games do
  let!(:game_player) { create(:game_player, wallet_addr: "0xlolarilole") }
  let!(:game_player1) { create(:game_player, wallet_addr: "0xlolarilole") }
  let!(:game_player2) { create(:game_player, wallet_addr: "0xlolarilole") }

  describe ".call" do
    it "returns the stats of games" do
      result = described_class.call("0xlolarilole")

      seconds_played = Game.in(players_wallet_addresses: "0xlolarilole").sum(:duration) / 1000
      total_games = GamePlayer.where(wallet_addr: "0xlolarilole").count
      total_wins = GamePlayer.where(wallet_addr: "0xlolarilole", winner: true).count
      wins_average = total_wins.to_f / total_games * 100

      expect(result.keys).to match_array(["seconds_played", "total_games", "total_wins", "wins_average"])
      expect(result["seconds_played"]).to eq(seconds_played)
      expect(result["total_games"]).to eq(total_games)
      expect(result["total_wins"]).to eq(total_wins)
      expect(result["wins_average"]).to eq(wins_average)
    end
  end
end
