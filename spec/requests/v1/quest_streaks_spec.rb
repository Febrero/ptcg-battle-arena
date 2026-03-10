require "rails_helper"

RSpec.describe "V1::QuestStreaks", type: :request do
  let!(:headers) do
    {"X-RealFevr-I-Token" => Rails.application.config.internal_api_key}
  end
  let(:quest_profile) { create(:quest_profile) }
  let(:quest_streak) { create(:quest_streak, profile: quest_profile) }

  describe "GET /v1/quest_streaks" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/quest_streaks", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "filters by profile id" do
        get "/v1/quest_streaks?filter[profile_id]=#{quest_streak.profile_id}", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/quest_streaks"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
