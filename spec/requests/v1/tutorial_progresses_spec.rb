require "rails_helper"

RSpec.describe "V1::TutorialProgresses", type: :request do
  let(:frontend_headers) { {"X-RealFevr-Token": Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s), Authorization: "xxx"} }
  let(:internal_headers) { {"X-RealFevr-I-Token": Rails.application.config.internal_api_key} }
  let!(:public_address) { "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2" }
  let!(:tutorial_progress) do
    create(:tutorial_progress, wallet_addr: public_address, wallet_addr_downcased: public_address.downcase) do |tutorial_progress|
      tutorial_progress.steps << build(:step, name: TutorialProgress::STEPS.first)
    end
  end

  describe "GET /v1/tutorial_progresses" do
    it "returns http success" do
      get "/v1/tutorial_progresses", headers: internal_headers

      expect(response).to have_http_status(:success)
      expect(json["data"].size).to eq(1)
    end

    it "returns http forbidden" do
      get "/v1/tutorial_progresses"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /v1/tutorial_progresses/:id" do
    it "returns http success" do
      get "/v1/tutorial_progresses/#{tutorial_progress.id}", headers: internal_headers

      expect(response).to have_http_status(:success)
    end

    it "returns http not found" do
      get "/v1/tutorial_progresses/tutorial_mais_loko", headers: internal_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns http forbidden" do
      get "/v1/tutorial_progresses/#{tutorial_progress.id}"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /v1/tutorial_progresses/new_step" do
    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => public_address})
    end

    it "returns http success" do
      post "/v1/tutorial_progresses/new_step", headers: frontend_headers, params: {
        step_name: TutorialProgress::STEPS.first
      }

      expect(response).to have_http_status(:success)
    end

    it "returns http bad request" do
      post "/v1/tutorial_progresses/new_step", headers: frontend_headers, params: {
        step_name: nil
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns http bad request" do
      post "/v1/tutorial_progresses/new_step", headers: frontend_headers, params: {
        step_name: "step_do_ze_da_esquina"
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns http unauthorized" do
      post "/v1/tutorial_progresses/new_step", params: {
        step_name: TutorialProgress::STEPS.first
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
