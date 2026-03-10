require "rails_helper"

RSpec.describe Survivals::FinishPlayersStreaks do
  let!(:season) { create(:season) }
  before do
    allow(Survivals::SendStreakEventToKafka).to receive(:call)
    allow(Survivals::GeneratePrize).to receive(:call)
  end

  it "should finished the streak of a given number of survival players (based on their ids)" do
    players = create_list(:survival_player, 3, entries: []) do |player|
      game = create(:game, game_mode_id: player.survival.uid)
      create(:game_player, game: game, wallet_addr: player.wallet_addr)

      player.begin_streak(123)
      # its necessary add ate least one game to the streak
      player.update_current_streak_level game.game_id
    end

    survival = create(:survival, uid: 1)
    create(:game, game_mode_id: survival.uid)

    create(:survival_player, entries: [], survival_id: survival.uid).begin_streak(123)

    expect {
      subject.call(players.map { |p| p.id.to_s })
    }.to change {
      SurvivalPlayer.ne(active_entry_id: nil).count
    }.from(4).to(1)
  end
end
