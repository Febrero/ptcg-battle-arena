require "rails_helper"

RSpec.describe AssistedGamers::ResetDailyGames, type: :service do
  describe "#call" do
    let!(:assisted_gamer1) { create(:assisted_gamer, todays_total_games_played: 213) }
    let!(:assisted_gamer2) { create(:assisted_gamer, todays_total_games_played: 80, wallet_addr: "0xqwerty") }
    before do
      AssistedGamers::ResetDailyGames.call
    end

    it "resets todays_total_games_played to 0 for all AssistedGamer records" do
      expect(assisted_gamer1.reload.todays_total_games_played).to eq(0)
      expect(assisted_gamer2.reload.todays_total_games_played).to eq(0)
    end
  end
end
