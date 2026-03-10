require "rails_helper"

RSpec.describe "V1::Playoff Teams", type: :request do
  let!(:headers_not_authorization) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key
    }
  end

  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET #index" do
    let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/playoff_teams"
        expect(response).to have_http_status(:forbidden)
      end
    end
    it "returns a successful response" do
      get "/v1/playoff_teams", headers: headers
      expect(response).to have_http_status(:success)
    end

    it "renders the playoff teams collection as JSON" do
      create(:playoffs_team)
      allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
        "profile_id" => {
          "username" => "ProfileUsername"
        }
      })

      get "/v1/playoff_teams", headers: headers
      expect(json["data"].size).to eq(1)
    end
  end

  describe "POST #create" do
    let(:user_data) { {"publicAddress" => "0x1234567890"} }

    context "with valid parameters" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_amount_needed: 3) }
      let(:spend_ticket_instance) { instance_double(Tickets::SpendTicketsPlayoff) }
      let(:valid_params) { {data: {attributes: {playoff_id: playoff.uid, ticket_id: ticket.bc_ticket_id.to_i}}} }
      let(:ticket_balance) { create(:ticket_balance, ticket: ticket, wallet_addr: "0x1234567890", deposited: 10) }
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:entry_already_charged?).and_return(false)
      end

      it "not user authenticated" do
        post "/v1/playoff_teams", params: valid_params, headers: headers_not_authorization
        expect(response).to have_http_status(:unauthorized)
      end

      it "creates a new playoff team" do
        allow(Playoffs::Notificator).to receive(:call)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User"}}})
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.to change(Playoffs::Team, :count).by(1)
      end

      it "returns a successful response" do
        allow(Playoffs::Notificator).to receive(:call)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User"}}})
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to be_successful
      end

      it "decreases the user ticket balance by playoff ticket amount needed" do
        allow(Playoffs::Notificator).to receive(:call)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User"}}})
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })

        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.to change { ticket_balance.reload.deposited }.by(-playoff.ticket_amount_needed)
      end

      it "renders the created playoff team as JSON" do
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User"}}})
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })
        allow(Playoffs::Notificator).to receive(:call)
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
        post "/v1/playoff_teams", params: valid_params, headers: headers
        playoff_team = Playoffs::Team.last
        serializer = V1::PlayoffTeamSerializer.new(playoff_team)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json
        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end

      it "no ticket balance" do
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"attributes" => {"username" => "Test User"}}})
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(false)
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to have_http_status(402)
        expect(json["error"]["code"]).to eq("insufficient_tickets")
      end

      it "max teams reached, revert ticket" do
        playoff = Playoff.first
        playoff.min_teams = 1
        playoff.max_teams = 1
        playoff.save

        create(:playoffs_team, playoff: playoff)

        allow(Tickets::SpendTicketsPlayoff).to receive(:new).and_return(spend_ticket_instance)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"attributes" => {"username" => "Test User"}}})

        allow(spend_ticket_instance).to receive(:charge).and_return(true)
        allow(spend_ticket_instance).to receive(:revert_charge_entry)

        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(spend_ticket_instance).to have_received(:revert_charge_entry)
        expect(json["base"]).to eq(["The playoff is already with maximum of teams"])
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { {data: {attributes: {playoff_id: nil, ticket_id: nil}}} }
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
      end
      it "does not create a new playoff team" do
        expect {
          post "/v1/playoff_teams", params: invalid_params, headers: headers
        }.not_to change(Playoffs::Team, :count)
      end

      it "returns a bad request response" do
        post "/v1/playoff_teams", params: invalid_params, headers: headers
        expect(response).to be_bad_request
      end

      it "renders the errors as JSON" do
        post "/v1/playoff_teams", params: invalid_params, headers: headers
        expect(response.body).to eq({errors: ["Playoff not exist"]}.to_json)
      end
    end
  end

  describe "GET #show" do
    context "when the playoff team exists" do
      let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let(:playoff_team) { create(:playoffs_team) }

      it "returns a successful response" do
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })
        get "/v1/playoff_teams/#{playoff_team.id}", headers: headers
        expect(response).to be_successful
      end

      it "renders the playoff team as JSON" do
        allow(GetProfilesByIds).to receive(:call).with(["profile_id"]).and_return({
          "profile_id" => {
            "username" => "ProfileUsername"
          }
        })
        serializer = V1::PlayoffTeamSerializer.new(playoff_team)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json
        get "/v1/playoff_teams/#{playoff_team.id}", headers: headers
        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end
    end

    context "when the playoff team does not exist" do
      it "returns a not found response" do
        get "/v1/playoff_teams/999", headers: headers
        expect(response).to be_not_found
      end
    end
  end

  describe "[CUSTOM PRIZE] Multiplier slot" do
    context "Min teams" do
      let(:user_data) { {"publicAddress" => "0x1234567890"} }
      let!(:ticket) { create(:ticket, base_price: 200, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let!(:playoff) { create(:playoff, rf_percentage: 0.0, burn_percentage: 0.0, possible_cashback_percentage: 0.0, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], has_custom_prize: true, min_teams: 4, multiplier_prize: 2) }
      let!(:playoff_team1) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team2) { create(:playoffs_team, playoff: playoff) }

      let(:spend_ticket_instance) { instance_double(Tickets::SpendTicketsPlayoff) }
      let(:valid_params) { {data: {attributes: {playoff_id: playoff.uid, ticket_id: ticket.bc_ticket_id.to_i}}} }
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
      end

      it "creates a new playoff team" do
        allow(Playoffs::Notificator).to receive(:call)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"attributes" => {"username" => "Test User"}}})
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(Playoff.first.prize_pool_winner_share).to eq(1600)
      end
    end

    context "[NEAREST PERCENTAGE] NEXT SLOT" do
      let(:user_data) { {"publicAddress" => "0x1234567890"} }
      let!(:ticket) { create(:ticket, base_price: 200, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let!(:playoff) { create(:playoff, rf_percentage: 0.0, burn_percentage: 0.0, possible_cashback_percentage: 0.0, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], has_custom_prize: true, min_teams: 4, multiplier_prize: 2) }
      let!(:playoff_team1) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team2) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team3) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team4) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team5) { create(:playoffs_team, playoff: playoff) }
      let!(:playoff_team6) { create(:playoffs_team, playoff: playoff) }

      let(:spend_ticket_instance) { instance_double(Tickets::SpendTicketsPlayoff) }
      let(:valid_params) { {data: {attributes: {playoff_id: playoff.uid, ticket_id: ticket.bc_ticket_id.to_i}}} }
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
        allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
      end

      it "creates a new playoff team" do
        allow(Playoffs::Notificator).to receive(:call)
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"attributes" => {"username" => "Test User"}}})
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(Playoff.first.prize_pool_winner_share).to eq(3200)
      end
    end

    context "[ON CREATE PLAYOFF]" do
      let!(:ticket) { create(:ticket, base_price: 200, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let!(:playoff) { create(:playoff, rf_percentage: 0.0, burn_percentage: 0.0, possible_cashback_percentage: 0.0, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], has_custom_prize: true, min_teams: 4, multiplier_prize: 2) }

      it "WINNER PRIZE SHARE WITH MINIMUN TEAMS" do
        expect(Playoff.first.prize_pool_winner_share).to eq(1600)
      end
    end

    context "[ON CREATE PLAYOFF CUSTOM PRIZE]" do
      let!(:ticket) { create(:ticket, base_price: 200, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let!(:playoff) { create(:playoff, rf_percentage: 0.0, burn_percentage: 0.0, possible_cashback_percentage: 0.0, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], has_custom_prize: true, min_teams: 4, total_prize_pool: 800) }

      it "WINNER PRIZE SHARE NOT CHANGE" do
        playoff = Playoff.first
        playoff.min_teams = 8
        playoff.save
        expect(Playoff.first.prize_pool_winner_share).to eq(800)
      end
    end

    context "[ON CREATE PLAYOFF NORMAL]" do
      let!(:ticket) { create(:ticket, base_price: 200, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
      let!(:playoff) { create(:playoff, rf_percentage: 5.0, burn_percentage: 4.0, possible_cashback_percentage: 1.0, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], has_custom_prize: false, min_teams: 4) }

      it "WINNER PRIZE SHARE CHANGE MIN TEAMS" do
        playoff = Playoff.first
        expect(playoff.prize_pool_winner_share).to eq(720.0)
        playoff.min_teams = 8
        playoff.save
        expect(playoff.prize_pool_winner_share).to eq(1440.0)
      end
    end
  end

  describe "XP level" do
    let(:user_data) { {"publicAddress" => "0x1234567890"} }
    let!(:ticket) { create(:ticket) }
    let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], min_xp_level: 5, max_xp_level: 10) }
    let(:spend_ticket_instance) { instance_double(Tickets::SpendTicketsPlayoff) }
    let(:valid_params) { {data: {attributes: {playoff_id: playoff.uid, ticket_id: ticket.bc_ticket_id.to_i}}} }

    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
      allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
      allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User", "xp_level" => 10}, "included" => [{"attributes" => {"url" => "avatar_url"}}]}})
    end

    context "when the team is within range" do
      before do
        allow_any_instance_of(Playoffs::GetTeamInfo).to receive(:xp_level).and_return(7)
      end

      it "returns a successful response" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to be_successful
      end

      it "creates a new playoff team" do
        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.to change(Playoffs::Team, :count).by(1)
      end

      it "renders the playoff team as JSON" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        playoff_team = Playoffs::Team.last
        serializer = V1::PlayoffTeamSerializer.new(playoff_team)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json
        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end
    end

    context "when the team is out of the range" do
      before do
        allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User", "xp_level" => 2}, "included" => [{"attributes" => {"url" => "avatar_url"}}]}})
      end

      it "returns a bad request response" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to be_bad_request
      end

      it "does not create a new playoff team" do
        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.not_to change(Playoffs::Team, :count)
      end

      it "renders the errors as JSON" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response.body).to eq({errors: ["You cant register in this playoff out of xp_level allowed"]}.to_json)
      end
    end
  end

  describe "White list" do
    let(:user_data) { {"publicAddress" => "0x1234567890"} }
    let!(:ticket) { create(:ticket) }
    let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], allow_only_wallets_in_whitelist: true) }
    let(:spend_ticket_instance) { instance_double(Tickets::SpendTicketsPlayoff) }
    let(:valid_params) { {data: {attributes: {playoff_id: playoff.uid, ticket_id: ticket.bc_ticket_id.to_i}}} }

    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
      allow_any_instance_of(Tickets::SpendTicketsPlayoff).to receive(:charge).and_return(true)
      allow(Profile::Fetch).to receive(:call).and_return({"data" => {"id" => "profile_id", "attributes" => {"username" => "Test User"}}})
    end

    context "when the team is white listed" do
      before do
        allow(Playoffs::WhiteList).to receive(:call).and_return(true)
      end

      it "returns a successful response" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to be_successful
      end

      it "creates a new playoff team" do
        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.to change(Playoffs::Team, :count).by(1)
      end

      it "renders the playoff team as JSON" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        playoff_team = Playoffs::Team.last
        serializer = V1::PlayoffTeamSerializer.new(playoff_team)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json
        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end
    end

    context "when the team is not white listed" do
      before do
        allow(Playoffs::WhiteList).to receive(:call).and_return(false)
      end

      it "returns a bad request response" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response).to be_bad_request
      end

      it "does not create a new playoff team" do
        expect {
          post "/v1/playoff_teams", params: valid_params, headers: headers
        }.not_to change(Playoffs::Team, :count)
      end

      it "renders the error as JSON" do
        post "/v1/playoff_teams", params: valid_params, headers: headers
        expect(response.body).to eq({errors: ["The wallet is not in allow list"]}.to_json)
      end
    end
  end
end
