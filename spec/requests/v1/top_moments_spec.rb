require "rails_helper"
RSpec.describe "V1::TopMomentsController", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let(:user_data) do
    {"publicAddress" => "0x123"}
  end

  describe "GET #show" do
    before do
      allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
      allow(NftStats::GenerateTopMoments).to receive(:call).and_return({top_moments: []})
    end

    it "authenticates the user" do
      expect(::Auth::User).to receive(:validate_auth)
      get "/v1/top_moments", headers: headers
    end

    it "calls NftStats::GenerateTopMoments with the user public address" do
      expect(NftStats::GenerateTopMoments).to receive(:call).with(user_data["publicAddress"]).and_return({top_moments: []})
      get "/v1/top_moments", headers: headers
    end

    it "renders the top moments JSON response" do
      get "/v1/top_moments", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({top_moments: []}.to_json)
    end
  end
end
