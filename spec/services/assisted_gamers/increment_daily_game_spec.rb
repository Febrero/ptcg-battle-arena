require "rails_helper"

RSpec.describe AssistedGamers::IncrementDailyGame, type: :service do
  describe "#call" do
    let!(:gamer1) { create(:assisted_gamer, wallet_addr: "addr1", todays_total_games_played: 2) }
    let!(:gamer2) { create(:assisted_gamer, wallet_addr: "addr2", todays_total_games_played: 3) }

    context "when incrementing games for selected gamers" do
      before do
        AssistedGamers::IncrementDailyGame.call(["addr1", "addr2"])
      end

      it "increments todays_total_games_played by 1 for the gamers with the specified wallet addresses" do
        expect(gamer1.reload.todays_total_games_played).to eq(3)
        expect(gamer2.reload.todays_total_games_played).to eq(4)
      end
    end
  end
end
