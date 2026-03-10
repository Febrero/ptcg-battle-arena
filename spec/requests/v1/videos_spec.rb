require "rails_helper"

RSpec.describe "V1::Videos", type: :request, vcr: true do
  let!(:headers) { {"X-RealFevr-Token": Rails.application.config.external_api_key, Authorization: "xxx"} }
  let!(:public_address) { "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2" }

  describe "GET /v1/index" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => public_address})
      get "/v1/videos", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
