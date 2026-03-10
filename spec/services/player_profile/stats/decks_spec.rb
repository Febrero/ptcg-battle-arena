require "rails_helper"

RSpec.describe PlayerProfile::Stats::Decks, vcr: true do
  let!(:deck1) { create(:deck, wallet_addr: "0x123") }
  let!(:deck2) { create(:deck, wallet_addr: "0x123") }
  let!(:deck3) { create(:deck, wallet_addr: "0x123") }
  let!(:deck4) { create(:deck, wallet_addr: "0x123") }
  let!(:deck5) { create(:deck, wallet_addr: "0x123") }
  let!(:deck6) { create(:deck, wallet_addr: "0x123") }
  let!(:deck7) { create(:deck, wallet_addr: "0x123") }
  let!(:deck8) { create(:deck, wallet_addr: "0x123") }
  let!(:deck9) { create(:deck, wallet_addr: "0x123") }
  let!(:deck10) { create(:deck, wallet_addr: "0x123") }

  describe ".call" do
    it "returns the stats of user decks" do
      result = described_class.call("0x123")

      expect(result.keys).to match_array((1..5).to_a.map(&:to_s))
      expect(result["1"]).to eq(Deck.where(wallet_addr: "0x123", stars: 1).count)
      expect(result["2"]).to eq(Deck.where(wallet_addr: "0x123", stars: 2).count)
      expect(result["3"]).to eq(Deck.where(wallet_addr: "0x123", stars: 3).count)
      expect(result["4"]).to eq(Deck.where(wallet_addr: "0x123", stars: 4).count)
      expect(result["5"]).to eq(Deck.where(wallet_addr: "0x123", stars: 5).count)
    end
  end
end
