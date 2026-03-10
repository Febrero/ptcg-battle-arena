require "rails_helper"

RSpec.describe V1::UserActivities::GameSerializer, type: :serializer, vcr: true do
  let!(:game) {
    create(:game, :arena, players_wallet_addresses: [
      "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
      "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b"
    ])
  }

  subject { V1::UserActivities::GameSerializer.new(game).serializable_hash }

  it "contains info related to quest activity" do
    expect(subject).to include(:game_mode_name, :players, :created_at)
  end
end
