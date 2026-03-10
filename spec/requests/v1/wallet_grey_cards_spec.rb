require "rails_helper"

RSpec.describe "V1::WalletGreyCards", type: :request do
  let(:wallet_addr) { "0x12312312312312" }
  let(:headers_frontend) do
    {
      "X-RealFevr-Token": Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s),
      Authorization: "xxx"
    }
  end

  let(:headers_internal_api) do
    {
      "X-RealFevr-I-Token": Rails.application.config.internal_api_key
    }
  end

  let!(:wallet_grey_card1) do
    create(
      :wallet_grey_card,
      wallet_addr: wallet_addr,
      grey_card_id: GreyCard.first.uid
    )
  end

  let!(:wallet_grey_card2) do
    create(
      :wallet_grey_card,
      wallet_addr: wallet_addr,
      grey_card_id: GreyCard.last.uid
    )
  end

  let!(:wallet_grey_card3) do
    create(
      :wallet_grey_card,
      wallet_addr: "xpto",
      grey_card_id: GreyCard.last.uid
    )
  end

  describe "GET /v1/index" do
    context "when authenticated" do
      it "returns http status success" do
        get "/v1/wallet_grey_cards", headers: headers_internal_api

        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http status forbidden" do
        get "/v1/wallet_grey_cards"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /v1/v1/show" do
    context "when authenticated" do
      it "returns a ok status" do
        get "/v1/wallet_grey_cards/#{wallet_grey_card1.id}", headers: headers_internal_api

        expect(response).to have_http_status(:ok)
      end
    end

    context "when wallet grey card does not exist" do
      it "returns http not found" do
        get "/v1/wallet_grey_cards/sdoasod", headers: headers_internal_api

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/wallet_grey_cards/#{wallet_grey_card1.id}"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /v1/wallet_grey_cards/wallet_collection" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => wallet_addr})
    end

    context "when authenticated" do
      it "returns http success" do
        get "/v1/wallet_grey_cards/wallet_collection", headers: headers_frontend

        expect(response).to have_http_status(:success)
        expect(json["data"].size).to eq(2)
      end
    end

    context "when not authenticated" do
      it "returns http success" do
        get "/v1/wallet_grey_cards/wallet_collection"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
