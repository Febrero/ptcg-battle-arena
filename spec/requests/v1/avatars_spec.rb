require "rails_helper"

RSpec.describe "V1::Deck", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/index" do
    context "when user is authenticated" do
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx")
        VCR.use_cassette "marketplaces_avatars_index" do
          get "/v1/avatars", headers: headers
        end
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is unauthenticated" do
      before do
        VCR.use_cassette "marketplaces_avatars_index" do
          get "/v1/avatars"
        end
      end

      it "returns http success" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
