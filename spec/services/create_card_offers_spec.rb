require "rails_helper"

RSpec.describe CreateCardOffers, type: :service, vcr: true do
  describe "#call" do
    let(:valid_params) do
      {
        card_type: "grey_card",
        offer_detail: {
          cards: [{uid: GreyCard.last.uid, quantity: 1}],
          create_starter_deck: true
        },
        wallet_addr: "valid_wallet_addr",
        reward_key: "valid_reward_key",
        source: "valid_source"
      }
    end

    let(:invalid_params) do
      {
        card_type: "invalid_type",
        offer_detail: {},
        wallet_addr: "invalid_wallet_addr",
        reward_key: "invalid_reward_key",
        source: "invalid_source"
      }
    end

    context "with valid parameters" do
      it "creates card offers, delivers cards, and generates a starter deck" do
        expect { CreateCardOffers.call(valid_params) }.to change { CardOffer.count }.by(1)
          .and change { WalletGreyCard.count }.by(1)
          .and change { Deck.count }.by(1)
      end
    end

    context "with invalid parameters" do
      it "raises InvalidCardOfferParams error" do
        expect { CreateCardOffers.call(invalid_params) }.to raise_error(InvalidCardOfferParams)
      end
    end
  end
end
