require "rails_helper"

RSpec.describe "V1::Decks", type: :request, vcr: true do
  let(:wallet_addr) { "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2" }

  let(:uids) { GreyCard.distinct(:uid) }

  let!(:wallet_grey_cards) do
    build_list(:wallet_grey_card, 50) do |wallet_grey_card, index|
      wallet_grey_card.wallet_addr = wallet_addr
      wallet_grey_card.grey_card_id = uids[index]
      wallet_grey_card.save!
    end
  end

  let!(:deck) do
    create(
      :deck,
      name: "deck1",
      nft_ids: [4, 5, 6],
      grey_card_ids: GreyCard.pluck(:uid)[1..37],
      # grey_card_ids: wallet_grey_cards.pluck(:uid)[1..37],
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
    )
  end

  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/decks/list" do
    before do
      get "/v1/decks/list?filter[wallet_addr]=0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2&sort=-updated_at,created_at", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/index" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})
      get "/v1/decks", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/show" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})

      get "/v1/decks/#{Deck.first.id}", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/decks/user" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})
      get "/v1/decks/user", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/show" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})

      get "/v1/decks/#{Deck.first.id}", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/user_show" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})

      get "/v1/decks/#{Deck.first.id}/user", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /v1/create" do
    context "context" do
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => Deck.first.wallet_addr})

        post "/v1/decks", headers: headers, params: {
          deck: {
            name: "abc",
            nft_ids: [4, 5, 6],
            grey_card_ids: wallet_grey_cards.pluck(:uid)[1..47],
            wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
          }
        }, as: :json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns error when deck name is more than 20" do
        post "/v1/decks", headers: headers,
          params: {
            deck: {
              name: "deck_name_deck_namedeck_name",
              nft_ids: (1..25).to_a,
              grey_card_ids: (1..25).to_a,
              wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
            }
          }, as: :json

        expect(json["name"]).to eq(["is too long (maximum is 20 characters)"])
      end

      it "returns error when cards more than 60" do
        post "/v1/decks", headers: headers, params: {
          deck: {
            name: "abcd",
            nft_ids: (1..35).to_a,
            grey_card_ids: (1..60).to_a,
            wallet_addr: "0x1231231231231231231231231231231231231231"
          }
        }, as: :json

        expect(response).to have_http_status(:bad_request)
      end

      it "returns error when nft less than 40" do
        post "/v1/decks", headers: headers, params: {
          deck: {
            name: "abcde",
            nft_ids: (1..15).to_a,
            grey_card_ids: GreyCard.pluck(:uid)[1..15].to_a,
            wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
          }
        }, as: :json

        card_sum = json["data"]["attributes"]["nfts"].count + json["data"]["attributes"]["grey_cards_count"]
        expect(card_sum).to be < 50
        expect(json["data"]["attributes"]["flag_status"]).to be(false)
      end

      it "returns error when position Goalkeeper less than 3 and nft's are >= 30" do
        post "/v1/decks", headers: headers, params: {
          deck: {
            name: "abcde",
            nft_ids: [4, 5, 6],
            grey_card_ids: GreyCard.pluck(:uid)[1..30].to_a,
            wallet_addr: "0x1231231231231231231231231231231231231231"
          }
        }, as: :json

        expect(json["data"]["attributes"]["nfts"].count).to eq(3)
        expect(json["data"]["attributes"]["flag_status"]).to be(false)
      end

      it "returns unique nfts when sending duplicate nfts" do
        post "/v1/decks", headers: headers, params: {
          deck: {
            name: "abcdef",
            nft_ids: [4, 4, 5, 5, 6, 6],
            wallet_addr: "0x1231231231231231231231231231231231231231"
          }
        }, as: :json

        expect(json["data"]["attributes"]["nfts"].count).to eq(3)
        expect(json["data"]["attributes"]["flag_status"]).to be(false)
      end
    end
  end

  describe "PUT /v1/update" do
    context "context" do
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => Deck.first.wallet_addr})

        put "/v1/decks/#{Deck.first.id}", headers: headers, params: {
          deck: {
            name: "abc1",
            nft_ids: [4, 5, 6].to_a,
            grey_card_ids: wallet_grey_cards.pluck(:uid)[1..37]
          }
        }, as: :json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "DELETE /v1/deck" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => Deck.first.wallet_addr})
      delete "/v1/decks/#{Deck.first.id}", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns the deleted deck result" do
      expect(json["success"]).to be(true)
    end
  end
end
