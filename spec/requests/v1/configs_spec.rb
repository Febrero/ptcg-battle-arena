require "rails_helper"

RSpec.describe "V1::Configs", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s),
      Authorization: "xxx"
    }
  end

  before do
    create(:standalone_build)
  end

  describe "GET /v1/index" do
    context "when user is authenticated" do
      it "returns http success" do
        get "/v1/configs", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is unauthenticated" do
      it "returns http success" do
        get "/v1/configs"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
