require "rails_helper"

describe "V1::Rewards", type: :request do
  describe "GET #wallet_rewards" do
    let(:game_id) { "2023-10-23" }
    let(:user_data) { {"publicAddress" => "abc123"} }
    let(:rewards) { {"default_reward" => [{"wallet_addr" => "0x123", "value" => "20", "reward_type" => "xp", "event_type" => "Arena", "reward_subtype" => nil}]} }
    let(:rewards_response) { {"default_reward" => [{"wallet_addr" => "0x123", "total_value" => "20", "reward_type" => "xp", "event_type" => "Arena", "reward_subtype" => nil, "cards_detail" => {}, "xp_detail" => []}]} }

    let!(:headers) do
      {
        "X-RealFevr-Token": Rails.application.config.external_api_key,
        Authorization: "xxx"
      }
    end
    let(:fake_redis) { instance_double("Redis") }
    before do
      allow_any_instance_of(V1::RewardsController).to receive(:get_redis).and_return(fake_redis)
      allow(Rewards::FetchWalletRewards).to receive(:call).and_return(rewards)
      allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0x123"})
    end

    context "when game is processing" do
      it "returns service_unavailable status code" do
        allow(fake_redis).to receive(:exists).with("#{game_id}::processing").and_return(1)
        get "/v1/rewards/wallet_rewards/#{game_id}", headers: headers
        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to eq("The endpoint is not ready. Please try again later.")
      end
    end

    context "when game is not processing" do
      it "returns OK status code with serialized rewards" do
        allow(fake_redis).to receive(:exists).with("#{game_id}::processing").and_return(0)
        get "/v1/rewards/wallet_rewards/#{game_id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(rewards_response["default_reward"].to_json)
      end
    end

    context "when Rewards::ServiceConnectionForbidden is raised" do
      before do
        allow(fake_redis).to receive(:exists).with("#{game_id}::processing").and_return(0)
        allow(Rewards::FetchWalletRewards).to receive(:call).and_raise(Rewards::ServiceConnectionForbidden)
      end

      it "returns forbidden status code" do
        get "/v1/rewards/wallet_rewards/#{game_id}", headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when Rewards::ServiceConnectionTimeout is raised" do
      before do
        allow(fake_redis).to receive(:exists).with("#{game_id}::processing").and_return(0)
        allow(Rewards::FetchWalletRewards).to receive(:call).and_raise(Rewards::ServiceConnectionTimeout)
      end

      it "returns request_timeout status code" do
        get "/v1/rewards/wallet_rewards/#{game_id}", headers: headers
        expect(response).to have_http_status(:request_timeout)
      end
    end

    context "when an unexpected error is raised" do
      before do
        allow(fake_redis).to receive(:exists).with("#{game_id}::processing").and_return(0)
        allow(Rewards::FetchWalletRewards).to receive(:call).and_raise("Unexpected error")
      end

      it "returns internal_server_error status code" do
        get "/v1/rewards/wallet_rewards/#{game_id}", headers: headers
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
