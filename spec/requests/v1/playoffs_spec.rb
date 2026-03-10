require "rails_helper"

RSpec.describe "V1::Playoffs", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let!(:ticket) { create(:ticket, bc_ticket_id: 1, base_price: 20_000, ticket_factory_contract_address: "0x123") }
  let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

  describe "GET #index" do
    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/playoffs"
        expect(response).to have_http_status(:forbidden)
      end
    end
    it "returns a successful response" do
      get "/v1/playoffs", headers: headers
      expect(response).to have_http_status(:success)
    end

    it "renders the playoffs collection as JSON" do
      get "/v1/playoffs", headers: headers
      expect(json["data"].size).to eq(1)
    end
  end

  describe "GET #show" do
    context "when the playoff exists" do
      it "returns a successful response" do
        get "/v1/playoffs/#{playoff.uid}", headers: headers
        expect(response).to be_successful
      end

      it "renders the playoff as JSON" do
        get "/v1/playoffs/#{playoff.uid}", headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the playoff does not exist" do
      it "returns a not found response" do
        get "/v1/playoffs/nonexistent", headers: headers
        expect(response).to be_not_found
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:prize_config) { create(:prize_config) }
      let(:valid_params) {
        {
          data: {
            attributes: attributes_for(:playoff, prize_config_id: prize_config.uid, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: ["1"])
          }
        }
      }

      it "creates a new playoff" do
        expect {
          post "/v1/playoffs", params: valid_params, headers: headers
        }.to change(Playoff, :count).by(1)
      end

      it "returns a successful response" do
        post "/v1/playoffs", params: valid_params, headers: headers
        expect(response).to be_successful
      end

      it "renders the created playoff as JSON" do
        post "/v1/playoffs", params: valid_params, headers: headers
        playoff = Playoff.last
        expect(json["data"]["attributes"]["uid"]).to eq(playoff.uid)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { {data: {attributes: {name: ""}}} }

      it "does not create a new playoff" do
        expect {
          post "/v1/playoffs", params: invalid_params, headers: headers
        }.not_to change(Playoff, :count)
      end

      it "returns a bad request response" do
        post "/v1/playoffs", params: invalid_params, headers: headers
        expect(response.status).to eq(422)
      end

      it "renders the errors as JSON" do
        post "/v1/playoffs", params: invalid_params, headers: headers
        name_error = json["errors"].find do |error|
          error["source"]["pointer"] == "/data/attributes/name"
        end
        expect(name_error["detail"]).to eq("can't be blank")
      end
    end
  end

  describe "PUT #update" do
    context "with valid parameters" do
      before do
        ticket = create(:ticket)
        create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s])
      end
      let(:valid_params) { {data: {attributes: {name: "New Name"}}} }

      it "updates the playoff" do
        put "/v1/playoffs/#{playoff.uid}", params: valid_params, headers: headers
        playoff.reload
        expect(playoff.name).to eq("New Name")
      end

      it "returns a successful response" do
        put "/v1/playoffs/#{playoff.uid}", params: valid_params, headers: headers
        expect(response).to be_successful
      end

      it "renders the updated playoff as JSON" do
        put "/v1/playoffs/#{playoff.uid}", params: valid_params, headers: headers
        serializer = V1::PlayoffSerializer.new(playoff.reload)
        serialized_data = ActiveModelSerializers::Adapter.create(serializer).to_json
        expect(json["data"]["attributes"].to_json).to eq(serialized_data)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { {data: {attributes: {name: ""}}} }

      it "does not update the playoff" do
        put "/v1/playoffs/#{playoff.uid}", params: invalid_params, headers: headers
        playoff.reload
        expect(playoff.name).not_to eq("")
      end

      it "returns a bad request response" do
        put "/v1/playoffs/#{playoff.uid}", params: invalid_params, headers: headers
        expect(response.status).to eq(422)
      end

      it "renders the errors as JSON" do
        put "/v1/playoffs/#{playoff.uid}", params: invalid_params, headers: headers
        name_error = json["errors"].find do |error|
          error["source"]["pointer"] == "/data/attributes/name"
        end
        expect(name_error["detail"]).to eq("can't be blank")
      end
    end
  end

  describe "GET #current_bracket" do
    context "when the playoff exists" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let(:user_data) { {"publicAddress" => "0x1234567890"} }

      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
        allow_any_instance_of(V1::PlayoffsController).to receive(:current_bracket_response)
        allow_any_instance_of(V1::PlayoffsController).to receive(:get_playoff).and_return(playoff)
        allow_any_instance_of(V1::PlayoffsController).to receive(:params).and_return({uid: playoff.uid})
        allow_any_instance_of(V1::PlayoffsController).to receive(:search_params).and_return({})
      end

      it "calls the current_bracket_response method" do
        expect_any_instance_of(V1::PlayoffsController).to receive(:current_bracket_response).with(user_data["publicAddress"])
        get "/v1/playoffs/#{playoff.uid}/current_bracket", headers: headers
      end
    end
    context "when the playoff exists but team is not in playoff" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let(:user_data) { {"publicAddress" => "0x1234567890"} }

      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)

        allow_any_instance_of(V1::PlayoffsController).to receive(:find_current_bracket).with(any_args).and_raise(Playoffs::TeamNotInPlayoff.new("TeamNotFound"))

        allow_any_instance_of(V1::PlayoffsController).to receive(:search_params).and_return({})
      end

      it "calls the current_bracket_response method" do
        get "/v1/playoffs/#{playoff.uid}/current_bracket", headers: headers
        expect(json["id"]).to eq(0)
      end
    end
    context "when the playoff but no exist bracket yet" do
      let!(:ticket) { create(:ticket) }
      let(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let(:user_data) { {"publicAddress" => "0x1234567890"} }

      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)

        allow_any_instance_of(V1::PlayoffsController).to receive(:find_current_bracket).with(any_args).and_raise(Playoffs::NoCurrentBracket.new("NoCurrentBracket"))

        allow_any_instance_of(V1::PlayoffsController).to receive(:search_params).and_return({})
      end

      it "calls the current_bracket_response method" do
        get "/v1/playoffs/#{playoff.uid}/current_bracket", headers: headers
        expect(json["id"]).to eq(1)
      end
    end

    context "when the playoff does not exist" do
      let(:user_data) { {"publicAddress" => "0x1234567890"} }
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx").and_return(user_data)
      end
      it "returns a not found response" do
        get "/v1/playoffs/nonexistent/current_bracket", headers: headers
        expect(response).to be_not_found
      end
    end
  end

  describe "GET #current_bracket_wallet" do
    context "when the playoff exists" do
      let!(:ticket) { create(:ticket) }
      let(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let(:wallet_addr) { "0x9876543210" }

      before do
        allow_any_instance_of(V1::PlayoffsController).to receive(:current_bracket_response)
        allow_any_instance_of(V1::PlayoffsController).to receive(:get_playoff).and_return(playoff)
        allow_any_instance_of(V1::PlayoffsController).to receive(:params).and_return({uid: playoff.uid, wallet_addr: wallet_addr})
        allow_any_instance_of(V1::PlayoffsController).to receive(:search_params).and_return({})
      end

      it "calls the current_bracket_response method" do
        expect_any_instance_of(V1::PlayoffsController).to receive(:current_bracket_response).with(wallet_addr)
        get "/v1/playoffs/#{playoff.uid}/current_bracket/#{wallet_addr}", headers: headers
      end
    end
  end
end
