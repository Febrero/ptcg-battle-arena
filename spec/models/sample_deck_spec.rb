require "rails_helper"

RSpec.describe SampleDeck, type: :model, vcr: true do
  subject(:sample_deck) { described_class.new }

  describe "Validations" do
    it "check validity of video ids" do
      sample_deck.video_ids = [-1, -2, -3]
      sample_deck.save
      expect(sample_deck.errors[:video_ids]).to include("Unpermitted video ids")
    end

    it "check validity of grey card ids" do
      sample_deck.grey_card_ids = [-1, -2, -3]
      sample_deck.save
      expect(sample_deck.errors[:grey_card_ids]).to include("Unpermitted grey card ids")
    end

    it "check maximum repeated grey cards" do
      sample_deck.grey_card_ids = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      sample_deck.save
      expect(sample_deck.errors[:grey_card_ids]).to include("Maximum repeated grey cards reached")
    end

    it "check maximum deck size" do
      sample_deck.grey_card_ids = (1..27).to_a
      sample_deck.video_ids = (1..27).to_a
      sample_deck.save
      expect(sample_deck.errors[:base]).to include("Maximum nfts per deck reached")
    end
  end
end
