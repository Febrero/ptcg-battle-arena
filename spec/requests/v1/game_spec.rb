require "rails_helper"

RSpec.describe "V1::Games", type: :request, b: :b do
  let!(:game) do
    create(
      :game,
      players_wallet_addresses: [
        "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
        "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb3"
      ]
    )
  end

  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/index" do
    it "returns http success" do
      get "/v1/games", headers: headers
      expect(response).to have_http_status(:success)
    end

    it "returns decks attributes" do
      get "/v1/games", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by player wallet_addr" do
      get "/v1/games?filter[players_wallet_addresses]=#{game.players_wallet_addresses.first}", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by player wallet_addr" do
      get "/v1/games?filter[players_wallet_addresses]=0x6c2005f258d8D1EF92D0a1E86b68e884d1808fb2,0x6c2005f258d8D1EF92d0A1E86b68e884d1808fb3", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by player wallet_addr" do
      get "/v1/games?filter[players_wallet_addresses]=blablablabla", headers: headers
      expect(json["data"].size).to eq(0)
    end

    it "filter game by player wallet_addr case insensitive" do
      get "/v1/games?filter[players_wallet_addresses]=#{"0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2".downcase}", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by player wallet_addr case insensitive" do
      get "/v1/games?filter[players_wallet_addresses]=0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by player wallet_addr case insensitive" do
      get "/v1/games?filter[players_wallet_addresses]=blabla", headers: headers
      expect(json["data"].size).to eq(0)
    end

    it "filter game by game_start_time lte" do
      get "/v1/games?filter[lte_game_start_time]=#{game.game_start_time - 1}", headers: headers
      expect(json["data"].size).to eq(0)
    end

    it "filter game by game_start_time lte" do
      get "/v1/games?filter[lte_game_start_time]=#{game.game_start_time + 1}", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by game_start_time gte" do
      get "/v1/games?filter[gte_game_start_time]=#{game.game_start_time - 1}", headers: headers
      expect(json["data"].size).to eq(1)
    end

    it "filter game by game_start_time gte" do
      get "/v1/games?filter[gte_game_start_time]=#{game.game_start_time + 1}", headers: headers
      expect(json["data"].size).to eq(0)
    end
  end

  describe "GET /v1/show" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/games/#{game.id}", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when game does not exist" do
      it "returns http not found" do
        get "/v1/games/fakeid", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/games/#{game.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /v1/show" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/games/by_game_id/#{game.game_id}", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when game does not exist" do
      it "returns http not found" do
        get "/v1/games/by_game_id/fakeid", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/games/by_game_id/#{game.game_id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /v1/games/info" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/games/info", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/games/info"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
