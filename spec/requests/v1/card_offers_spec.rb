require "rails_helper"

RSpec.describe "V1::CardOffers", type: :request do
  let!(:card_offer) { create(:card_offer) }

  let!(:headers_internal_api) do
    {"X-RealFevr-I-Token" => Rails.application.config.internal_api_key}
  end

  describe "GET /v1/card_offers" do
    context "when authentiacated" do
      it "returns http success" do
        get "/v1/card_offers", headers: headers_internal_api

        expect(response).to have_http_status(:success)
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        get "/v1/card_offers"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /v1/card_offers/:id" do
    context "when authentiacated" do
      it "returns http success" do
        get "/v1/card_offers/#{card_offer.id}", headers: headers_internal_api

        expect(response).to have_http_status(:success)
      end

      it "returns http not found" do
        get "/v1/card_offers/fake_id", headers: headers_internal_api

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        get "/v1/card_offers/#{card_offer.id}"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/card_offers" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/card_offers", headers: headers_internal_api, params: {
          wallet_addr: "0xpto",
          quantity: 1,
          card_type: "grey_card",
          offer_detail: {cards: [{uid: GreyCard.first.uid}]},
          reward_key: "BLABLA",
          source: "reward"
        }

        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/card_offers", params: {
          wallet_addr: "0xpto",
          quantity: 1,
          card_type: "grey_card",
          offer_detail: {cards: [{uid: GreyCard.first.uid}]},
          reward_key: "BLABLA",
          source: "reward"
        }
        expect(response).to have_http_status(:forbidden)
      end

      it "returns http bad request" do
        post "/v1/card_offers", headers: headers_internal_api, params: {
          wallet_addr: "0xpto",
          quantity: 1,
          card_type: "grey_card",
          offer_detail: {cards: [{uid: -1}]},
          reward_key: "BLABLA",
          source: "reward"

        }
        expect(response).to have_http_status(:bad_request)
      end

      it "returns http bad request" do
        post "/v1/card_offers", headers: headers_internal_api, params: {
          # without wallet addr
          quantity: 1,
          card_type: "grey_card",
          offer_detail: {cards: [{uid: GreyCard.first.uid}]},
          reward_key: "BLABLA",
          source: "reward"
        }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
