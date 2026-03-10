require "rails_helper"

RSpec.describe Arenas::GeneratePrize, vcr: true do
  let!(:arena) { create(:arena) }
  let!(:game) { create(:game, game_mode_id: arena.uid) }
  let!(:game_player) { create(:game_player, game: game) }

  let(:prize_msg) do
    {
      game_id: game.game_id,
      ticket_id: game_player.ticket_id,
      ticket_amount: game_player.ticket_amount,
      erc20: arena.token["address"],
      erc20_name: arena.erc20_name,
      match_type: "Arena",
      game_mode: "Arena",
      game_mode_id: arena.uid,
      survival_levels_completed: nil,
      survival_max_level: nil,
      wallet_addr: game_player.wallet_addr,
      prize_awarded: game_player.winner,
      total_prize_amount: game_player.prize_amount,
      total_prize_winner_share: game_player.prize_amount * arena.winner_share,
      total_prize_realfevr_share: game_player.prize_amount * arena.rf_share,
      total_prize_burn_share: game_player.prize_amount * arena.burn_share
    }
  end

  before do
    allow(subject).to receive(:publish_to_rabbimtq_exchange)
  end

  it "should send a message to rabbitmq with arena prize resume" do
    subject.call(arena, game_player, game.game_id)

    expect(subject).to have_received(:publish_to_rabbimtq_exchange).with(prize_msg).once
  end
end
