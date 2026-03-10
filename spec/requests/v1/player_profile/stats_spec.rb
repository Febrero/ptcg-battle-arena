require "rails_helper"

RSpec.describe "V1::PlayerProfile::Stats", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s),
      Authorization: "xxx"
    }
  end

  describe "GET /v1/player_profile/stats/games" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "x0sad1w"})

        get "/v1/player_profile/stats/games", headers: headers

        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/player_profile/stats/games"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /v1/player_profile/stats/decks" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "x0sad1w"})

        get "/v1/player_profile/stats/decks", headers: headers

        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/player_profile/stats/decks"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /v1/player_profile/stats/moments" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "x0sad1w"})

        get "/v1/player_profile/stats/moments", headers: headers

        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/player_profile/stats/moments"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
