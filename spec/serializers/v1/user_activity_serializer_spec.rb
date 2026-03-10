require "rails_helper"

RSpec.describe V1::UserActivitySerializer, type: :serializer do
  let!(:survival_player) { create(:survival_player, wallet_addr: "0x123") }
  let!(:game) { create(:game, :arena) }
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

  context "when user activity is type survival" do
    subject { V1::UserActivitySerializer.new(user_activity_survival).serializable_hash }

    it "contains info related to survival activity" do
      expect(subject).to include(:wallet_addr, :event_data, :source_type, :created_at)
      expect(subject[:event_data]).to include(:game_mode_name, :wins)
    end
  end

  context "when user activity is type game" do
    subject { V1::UserActivitySerializer.new(user_activity_game).serializable_hash }

    it "contains info related to game activity" do
      expect(subject).to include(:wallet_addr, :event_data, :source_type, :created_at)
      expect(subject[:event_data]).to include(:game_mode_name, :winner, :goals_scored, :goals_conceded)
    end
  end

  context "when user activity is type quest" do
    subject { V1::UserActivitySerializer.new(user_activity_quest).serializable_hash }

    it "contains info related to daily quest activity" do
      expect(subject).to include(:wallet_addr, :event_data, :source_type, :created_at)
      expect(subject[:event_data]).to include(:day)
    end
  end
end
