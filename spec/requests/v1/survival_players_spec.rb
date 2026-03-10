require "rails_helper"

RSpec.describe "V1::SurvivalPlayers", type: :request do
  let!(:headers) do
    {"X-RealFevr-Token" => Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s),
     "Authorization" => "xxx"}
  end

  let(:wallet_addr1) { "0xABCD1234" }
  let(:wallet_addr2) { "0xFOOBAR69" }

  before do
    create_list(:survival, 2, :active).each do |active_survival|
      create(:survival_player, survival: active_survival, wallet_addr: wallet_addr1)
    end

    closed_survival = create(:survival, :closed)
    create(:survival_player, survival: closed_survival, wallet_addr: wallet_addr1)
    create(:survival_player, survival: closed_survival, wallet_addr: wallet_addr2)
  end

  describe "Not authorized survival requests" do
    it "index returns not authorized" do
      get "/v1/survival_players", headers: {}
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET index" do
    context "without filters" do
      before { get "/v1/survival_players", headers: headers }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a survival players list" do
        expect(json["data"].size).to eq(4)
      end
    end

    # context "with filters" do
    #   it "filter by survival_id" do
    #   	survivals.first(2).each { |s| s.update_attributes(state: "closed") }

    #   	get "/survival_players?filter[state]=closed", headers: headers

    #     expect(json["data"].size).to eq(2)
    #   end
    # end
  end

  describe "GET current_entry" do
    let(:game) { create(:game) }
    let(:survival) { create(:survival) }
    let(:survival_player) do
      create(:survival_player, survival: survival, entries: []).tap do |player|
        player.begin_streak(12345)
        player.update_current_streak_level(game.game_id)
        player.update_current_streak_level(game.game_id)
      end
    end

    it "returns not authorized" do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0xWALLET_AUTHENTICATED"})

      get "/v1/survival_player/current_entry", headers: {}, params: {}

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found if no survival_player was found" do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0xWALLET_WITHOUT_ENTRIES"})

      get "/v1/survival_player/current_entry", headers: headers, params: {survival_id: survival.uid}

      expect(response).to have_http_status(:not_found)
    end

    it "returns not found if no entry was found" do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "0xWALLET_WITHOUT_ENTRIES"})

      create(:survival_player, wallet_addr: "0xWALLET_WITHOUT_ENTRIES", survival: survival, entries: [])

      get "/v1/survival_player/current_entry", headers: headers, params: {survival_id: survival.uid}

      expect(response).to have_http_status(:not_found)
    end

    it "returns 200 if and entry is returned" do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => survival_player.wallet_addr})

      get "/v1/survival_player/current_entry", headers: headers, params: {survival_id: survival.uid}

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    let(:wallet_authenticated) { "0xWALLET_AUTHENTICATED" }

    before do
      allow(Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => wallet_authenticated})
    end

    it "create returns not authorized" do
      post "/v1/survival_players", headers: {}, params: {
        data: {
          attributes: {}
        }
      }
      expect(response).to have_http_status(:unauthorized)
    end

    it "should return bad_request if Survivals::PlayerFieldsMissing is raised" do
      allow(Survivals::GeneratePlayer).to receive(:call).and_raise(Survivals::PlayerFieldsMissing)

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: nil,
            ticket_id: nil,
            wallet_addr: nil
          }
        }
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "should return bad_request if Survivals::MultipleActiveStreak is raised" do
      allow(Survivals::GeneratePlayer).to receive(:call).and_raise(Survivals::MultipleActiveStreak.new(:foo, :bar))

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: nil,
            ticket_id: nil,
            wallet_addr: nil
          }
        }
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "should return bad_request if Survivals::TicketNotSpent is raised" do
      allow(Survivals::GeneratePlayer).to receive(:call).and_raise(Survivals::TicketNotSpent)

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: nil,
            ticket_id: nil,
            wallet_addr: nil
          }
        }
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "should return 200 if no exception is raise" do
      survival = create(:survival, :active)
      survival_player = create(:survival_player, survival: survival, wallet_addr: "0xQWEASDFOOBAR")

      allow(Survivals::GeneratePlayer).to receive(:call).and_return(survival_player)

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: survival.uid,
            ticket_id: 12345,
            wallet_addr: survival_player.wallet_addr
          }
        }
      }

      expect(response).to have_http_status(:ok)
    end

    it "should call the service using the user authenticated wallet_addr" do
      survival = create(:survival, :active)

      allow(Survivals::GeneratePlayer).to receive(:call)

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: survival.uid,
            ticket_id: 12345,
            wallet_addr: "0xWALLET_BY_PARAMS"
          }
        }
      }

      expect(Survivals::GeneratePlayer).to have_received(:call).with(wallet_authenticated, any_args).once
    end

    xit "should call the service using the wallet_addr passed on the parameters" do
      params_wallet = "0xWALLET_BY_PARAMS"
      survival = create(:survival, :active)

      allow(Survivals::GeneratePlayer).to receive(:call)

      post "/v1/survival_players", headers: headers, params: {
        data: {
          attributes: {
            survival_uid: survival.uid,
            ticket_id: 12345,
            wallet_addr: params_wallet
          }
        }
      }

      expect(Survivals::GeneratePlayer).to have_received(:call).with(params_wallet, any_args).once
    end
  end
end

# allow(Auth::User).to receive(:validate_auth).with("xxx")
#   .and_return({"publicAddress" => Deck.first.wallet_addr})
