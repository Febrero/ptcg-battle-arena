require "rails_helper"

RSpec.describe Arenas::ProcessGame do
  let!(:arena) { create(:arena) }
  let!(:game) do
    game = create(:game, game_mode_id: arena.uid, match_type: "Arena") do |game|
      create_list(:game_player, 2, game: game)
    end

    game.update_attributes(winner: GamePlayer.last.wallet_addr)

    game
  end

  before do
    allow(Arenas::CalculatePrizeValue).to receive(:call)
  end

  it "should calcluate prizes info for the winner" do
    allow(Arenas::GeneratePrize).to receive(:call).with(any_args).twice

    subject.call(game, game.to_original_request)

    expect(Arenas::CalculatePrizeValue).to have_received(:call).with(any_args, game.winner).once
  end

  it "should generate prizes for this arena" do
    allow(Arenas::GeneratePrize).to receive(:call).with(any_args).twice
    subject.call(game, game.to_original_request)

    expect(Arenas::GeneratePrize).to have_received(:call).with(any_args).twice
  end
end
