require "rails_helper"

RSpec.describe "V1::PlayerProfile::UserActivities", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s),
      Authorization: "xxx"
    }
  end
  let!(:survival_game) do
    create(
      :game,
      :survival,
      players_wallet_addresses: [
        "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
        "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b"
      ]
    )
  end
  let!(:survival_player1) { create(:game_player, game: survival_game, wallet_addr: "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee") }
  let!(:survival_player2) { create(:game_player, game: survival_game, wallet_addr: "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b") }
  let!(:survival_player) do
    create(
      :survival_player,
      wallet_addr: "0x123",
      entries: [{games_ids: [survival_game.game_id]}]
    )
  end
  let!(:game) {
    create(:game, :arena, players_wallet_addresses: [
      "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
      "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b"
    ])
  }
  let!(:game_player) { create(:game_player, game: game, wallet_addr: "0x123") }
  let!(:quest_profile) { create(:quest_profile) }
  let!(:user_activity_survival) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {entry_id: survival_player.current_entry.id},
      source: survival_player.survival
    )
  end
  let!(:user_activity_game) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {game_id: game_player.game.game_id},
      source: game_player.game.game_mode
    )
  end
  let!(:user_activity_quest) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {day: quest_profile.count},
      source: quest_profile.quest
    )
  end

  describe "GET /v1/user" do
    context "when user is authenticated" do
      before do
        allow(Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "0x123"})
      end

      it "returns http success" do
        get "/v1/player_profile/user_activities/user", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is unauthenticated" do
      it "returns http success" do
        get "/v1/player_profile/user_activities/user"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /v1/show" do
    context "when user is authenticated" do
      it "returns http success" do
        get "/v1/player_profile/user_activities/#{user_activity_survival.id}", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "returns http not found if user activity does not exist" do
        get "/v1/player_profile/user_activities/xalala", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is unauthenticated" do
      it "returns http success" do
        get "/v1/player_profile/user_activities/#{user_activity_survival.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
