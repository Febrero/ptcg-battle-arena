require "rails_helper"

RSpec.describe "V1::AssistedGamers", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  let!(:assisted_gamers) { build_list(:assisted_gamer, 10).each_with_index { |ag, i| ag.update_attributes(wallet_addr: "0xWALLET-#{i}") } }

  describe "GET /v1/search" do
    before do
      VCR.insert_cassette "AssistedGamers/GET_/search/Authenticated/returns_http_success"
    end
    context "Authenticated" do
      let!(:assisted_gamer) {
        create(:assisted_gamer)
      }
      let!(:deck) {
        create(
          :deck,
          :two_stars,
          wallet_addr: assisted_gamer.wallet_addr
        )
      }

      before do
        # expect(GetProfilesByWalletAddresses).to receive(:call).with(filter: {wallet_addr: assisted_gamer.wallet_addr}).and_return({})
        Deck.update_all(stars: 2, flag_status: true)

        get "/v1/assisted_gamers/search?deck_stars=2", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "Not authenticated" do
      before do
        get "/v1/assisted_gamers/search?deck_stars=2", headers: {}
      end
      it "returns http unauthorized" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #index" do
    context "Authenticated" do
      it "returns a successful response" do
        get "/v1/assisted_gamers", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "renders the assisted gamers collection as JSON" do
        get "/v1/assisted_gamers", headers: headers
        expect(json["data"].size).to eq(assisted_gamers.count)
      end
    end

    context "Not authenticated" do
      it "returns http forbidden" do
        get "/v1/assisted_gamers"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #show" do
    context "when the assisted gamer exists" do
      it "returns a successful response" do
        get "/v1/assisted_gamers/#{assisted_gamers[0].id}", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "renders the assisted gamer as JSON" do
        get "/v1/assisted_gamers/#{assisted_gamers[0].id}", headers: headers
        expect(json["data"]).to be_truthy
      end
    end

    context "when the assisted gamer does not exist" do
      it "returns a not found response" do
        get "/v1/assisted_gamers/123", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) {
        {
          data: {
            attributes: attributes_for(:assisted_gamer)
          }
        }
      }

      it "creates a new assisted gamer" do
        expect {
          post "/v1/assisted_gamers", params: valid_params, headers: headers
        }.to change(AssistedGamer, :count).by(1)
      end

      it "returns a successful response" do
        post "/v1/assisted_gamers", params: valid_params, headers: headers
        expect(response).to have_http_status(:success)
      end

      it "renders the created assisted gamer as JSON" do
        post "/v1/assisted_gamers", params: valid_params, headers: headers
        assisted_gamer = AssistedGamer.last
        expect(json["data"]["id"]).to eq(assisted_gamer.id.to_s)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { {data: {attributes: {wallet_addr: ""}}} }

      it "does not create a new assisted gamer" do
        expect {
          post "/v1/assisted_gamers", params: invalid_params, headers: headers
        }.not_to change(AssistedGamer, :count)
      end

      it "returns an unprocessable entity response" do
        post "/v1/assisted_gamers", params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the errors as JSON" do
        post "/v1/assisted_gamers", params: invalid_params, headers: headers

        expect(json).to have_key("errors")
      end
    end
  end

  describe "PUT #update" do
    let(:assisted_gamer) { assisted_gamers[0] }

    context "with valid parameters" do
      let(:valid_params) {
        {
          data: {
            attributes: {
              wallet_addr: "0x123"
            }
          }
        }
      }

      it "updates the assisted gamer" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: valid_params, headers: headers
        assisted_gamer.reload

        expect(assisted_gamer.wallet_addr).to eq("0x123")
      end

      it "returns a sucessful response" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: valid_params, headers: headers

        expect(response).to have_http_status(:success)
      end

      it "renders the updated assisted gamer as JSON" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: valid_params, headers: headers
        serializer = V1::AssistedGamerSerializer.new(assisted_gamer.reload)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json

        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) {
        {
          data: {
            attributes: {
              wallet_addr: ""
            }
          }
        }
      }

      it "does not update the assisted gamer" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: invalid_params, headers: headers
        assisted_gamer.reload

        expect(assisted_gamer.wallet_addr).not_to be_empty
      end

      it "returns an unprocessable entity response" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the errors as JSON" do
        put "/v1/assisted_gamers/#{assisted_gamer.id}", params: invalid_params, headers: headers

        expect(json).to have_key("errors")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:assisted_gamer) { assisted_gamers[0] }

    it "destroys the assisted gamer" do
      expect {
        delete "/v1/assisted_gamers/#{assisted_gamer.id}", headers: headers
      }.to change(AssistedGamer, :count).by(-1)
    end

    it "returns a no content response" do
      delete "/v1/assisted_gamers/#{assisted_gamer.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end
end
