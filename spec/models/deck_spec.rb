require "rails_helper"

RSpec.describe Deck, type: :model, vcr: true do
  subject(:deck) { described_class.new }
  let!(:wallet_grey_cards) do
    build_list(:wallet_grey_card, 27) do |wallet_grey_card, index|
      wallet_grey_card.wallet_addr = "0x1231231231231231231231231231231231231231"
      wallet_grey_card.grey_card_id = index + 1
      wallet_grey_card.save!
    end
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:wallet_addr) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:wallet_addr) }
    it { is_expected.to validate_length_of(:name).with_maximum(::Deck::MAX_NAME_CHARACTER_COUNT) }
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(background: true) }

    it "check wallet decks count limit" do
      create_list(:deck, 20, wallet_addr: "0x1231231231231231231231231231231231231231")
      deck.wallet_addr = "0x1231231231231231231231231231231231231231"
      deck.save

      expect(deck.errors[:base]).to include("Maximum number of decks reached")
    end

    it "check maximum deck size" do
      deck.nft_ids = (1..27).to_a
      deck.grey_card_ids = (1..27).to_a
      deck.wallet_addr = "0x1231231231231231231231231231231231231231"
      deck.save
      expect(deck.errors[:base]).to include("Maximum cards per deck reached")
    end

    it "check maximum repeated nfts" do
      # nfts with same video id
      nfts_with_same_video_id = [285984, 285985, 285988, 286008, 286029, 286033]
      deck.nft_ids = (1..44).to_a + nfts_with_same_video_id
      deck.wallet_addr = "0x1231231231231231231231231231231231231231"
      deck.save
      expect(deck.errors[:nft_ids]).to include("Maximum repeated moments reached")
    end

    it "calculates the correct stars" do
      deck1 = create(
        :deck,
        name: "deck xpto",
        nft_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 25, 294599, 294626, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 286325, 286332, 286339, 286346, 286366, 286372, 286379, 286406, 286409, 286426, 286431, 286441, 286469, 936], # legendary nft
        grey_card_ids: [],
        wallet_addr: "0x1231231231231231231231231231231231231231"
      )

      expect(deck1.reload.stars).to eq(3)
    end
  end
end
