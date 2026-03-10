require "rails_helper"

RSpec.describe "V1::Leaderboards", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token" => Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s)
    }
  end
  let(:headers_leaderboards_api) do
    {
      headers: {
        "X-RealFevr-I-Token": Rails.application.config.realfevr_services[:leaderboards][:internal_api_key],
        "X-RealFevr-E-Token": Rails.application.config.realfevr_services[:leaderboards][:external_api_key],
        "X-RealFevr-Token": Rails.application.config.realfevr_services[:leaderboards][:external_api_key]
      }
    }
  end

  let(:leaderboards_api_base_url) do
    service = Rails.application.config.realfevr_services["leaderboards"]
    service[:service]
  end

  let(:leaderboard_request) do
    ActionController::Parameters.permit_all_parameters = true
    params = ActionController::Parameters.new({})

    allow(HTTParty).to receive(:get).with(
      "#{leaderboards_api_base_url}/leaderboards/battle_arena/",
      {query: params}.merge(headers_leaderboards_api)
    )
  end

  describe "GET Leaderboards not authorized" do
    it "returns not authorized" do
      get "/v1/leaderboards/battle_arena", headers: {}
      expect(response).to have_http_status(:forbidden)
    end
  end
  describe "GET Leaderboards" do
    it "returns http not found" do
      get "/v1/leaderboards/marketplace", headers: headers
      expect(response).to have_http_status(:not_found)
    end
    it "returns http status ok" do
      dbl_response = double("Response", body: ["leaderboards"].to_json, code: 200)
      leaderboard_request.and_return(dbl_response)
      get "/v1/leaderboards/battle_arena", headers: headers
      expect(response).to have_http_status(:ok)
    end
    it "return service_unvailable on exception econnrefused" do
      leaderboard_request.and_raise(Errno::ECONNREFUSED)
      get "/v1/leaderboards/battle_arena", headers: headers
      expect(response).to have_http_status(:service_unavailable)
    end
    it "return service_unvailable on exception timeout" do
      dbl_response = double("Response", body: nil, code: 408)

      leaderboard_request.and_return(dbl_response)
      get "/v1/leaderboards/battle_arena", headers: headers

      expect(response).to have_http_status(:service_unavailable)
    end
    it "return not found if endpoint not exist in remote request" do
      dbl_response = double("Response", body: nil, code: 404)

      leaderboard_request.and_return(dbl_response)

      get "/v1/leaderboards/battle_arena", headers: headers
      expect(response).to have_http_status(:not_found)
    end
    it "return internal_server_error on general error" do
      allow(LeaderboardsSearch).to receive(:new).and_raise(StandardError)

      get "/v1/leaderboards/battle_arena", headers: headers
      expect(response).to have_http_status(:internal_server_error)
    end

    it "only accept allowed paramaters" do
      ActionController::Parameters.permit_all_parameters = true
      filter_parameters = ActionController::Parameters.new({key: "202022", username: "luis", wallet_addr: "0x123"})
      page_params = ActionController::Parameters.new({page: "1", per_page: "100"})
      params = ActionController::Parameters.new({page: page_params,
                                                  order: "current_position_desc",
                                                  filter: filter_parameters})

      expect(HTTParty).to receive(:get).with(
        "#{leaderboards_api_base_url}/leaderboards/battle_arena/",
        {query: params}.merge(headers_leaderboards_api)
      )

      get "/v1/leaderboards/battle_arena?not_allowed=123&page[page]=1&page[per_page]=100&order=current_position_desc&filter[key]=202022&filter[username]=luis&filter[wallet_addr]=0x123&filter[not_allowed]=123",
        headers: headers
    end
  end
end
