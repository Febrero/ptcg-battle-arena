require "rails_helper"

RSpec.describe Survivals::GeneratePrize, vcr: true do
  let(:game) { create(:game) }
  let(:survival_player) { create(:survival_player) }

  let(:prize_msg) do
    create(:game_player, game: game, wallet_addr: survival_player.wallet_addr)
    survival = survival_player.survival
    current_entry = survival_player.current_entry
    stage_completed = survival.stages.find_by(level: current_entry.levels_completed)

    {game_id: game.game_id,
     ticket_id: current_entry.ticket_id,
     ticket_amount: current_entry.ticket_amount,
     erc20: survival.token["address"],
     erc20_name: survival.erc20_name,
     match_type: "Survival",
     game_mode: "Survival",
     game_mode_id: survival.uid,
     survival_levels_completed: current_entry.levels_completed,
     survival_max_level: survival.levels_count,
     wallet_addr: survival_player.wallet_addr,
     prize_awarded: (current_entry.levels_completed > 0),
     total_prize_amount: stage_completed.prize_amount,
     total_prize_winner_share: stage_completed.prize_amount * survival.winner_share,
     total_prize_realfevr_share: stage_completed.prize_amount * survival.rf_share,
     total_prize_burn_share: stage_completed.prize_amount * survival.burn_share}
  end

  before do
    allow(subject).to receive(:publish_to_rabbimtq_exchange)
  end

  it "should send a message to rabbitmq with survival prize resume" do
    subject.call survival_player.survival, survival_player, game.game_id

    expect(subject).to have_received(:publish_to_rabbimtq_exchange).with(prize_msg).once
  end
end
