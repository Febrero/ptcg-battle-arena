require "rails_helper"

RSpec.describe "V1::GreyCards", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/index" do
    before do
      allow(::Auth::User).to receive(:validate_auth).with("xxx")
        .and_return({"publicAddress" => "x0sad1w"})
      get "/v1/grey_cards", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
