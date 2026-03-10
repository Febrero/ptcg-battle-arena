require "rails_helper"

RSpec.describe "V1::WhiteLists", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/white_list/:address" do
    it "returns http success" do
      VCR.use_cassette "white_list_presence" do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0x5a550FddA8619762D6cB792022F36f774F5fa2c1"})
        get "/v1/white_list/0x5a550FddA8619762D6cB792022F36f774F5fa2c1", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    it "returns wallet data" do
      VCR.use_cassette "white_list_presence" do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0x5a550FddA8619762D6cB792022F36f774F5fa2c1"})
        get "/v1/white_list/0x5a550FddA8619762D6cB792022F36f774F5fa2c1", headers: headers
        expect(json["data"]["attributes"]["address"]).to eq("0x5a550FddA8619762D6cB792022F36f774F5fa2c1")
        expect(json["data"]["attributes"]["roles"]).to eq(["admin"])
      end
    end

    it "returns 404 error if wallet is not present" do
      VCR.use_cassette "white_list_presence_not_found" do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0x5a550FddA8619762D6cB792022F36f774F5fa2c1"})
        get "/v1/white_list/0xNotIncludedInWhiteListAddress", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns http forbidden when authorization is not passed" do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0x5a550FddA8619762D6cB792022F36f774F5fa2c1"})
      get "/v1/white_list/0x5a550FddA8619762D6cB792022F36f774F5fa2c1"
      expect(response).to have_http_status(:forbidden)
    end
  end
end
