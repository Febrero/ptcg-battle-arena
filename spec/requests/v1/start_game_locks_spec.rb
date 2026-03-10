require "rails_helper"

RSpec.describe "V1::StartGameLocks", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "POST /v1/lock" do
    context "Authenticated" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        post "/v1/start_game_locks/lock", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "Not authenticated" do
      before do
        post "/v1/start_game_locks/lock"
      end

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
