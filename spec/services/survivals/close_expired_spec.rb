require "rails_helper"

RSpec.describe Survivals::CloseExpired do
  let!(:season) { create(:season) }
  before do
    allow(Survivals::SendStreakEventToKafka).to receive(:call)
  end

  describe "update of survival state" do
    it "should close all active survivals that passed the end_date" do
      create_list(:survival, 2, :active, end_date: (Time.now - 10.days))
      create(:survival, :active)

      expect {
        subject.call
      }.to change {
             Survival.closed.count
           }.from(0).to(2)
    end

    it "should not close active survivals with future end_date" do
      create_list(:survival, 2, :active, end_date: (Time.now - 10.days))
      create(:survival, :active)

      expect {
        subject.call
      }.to change {
        Survival.active.count
      }.from(3).to(1)
    end
  end

  it "should only fetch all the survival_players with active streak" do
    allow(Survivals::FinishPlayersStreaksJob).to receive(:perform_in)
    allow(Survivals::SendStreakEventToKafka).to receive(:call)
    allow(Survivals::GeneratePrize).to receive(:call)
    allow(subject).to receive(:return_tickets_to_players_without_games).and_return(nil)

    survival = create(:survival, :active, end_date: (Time.now - 10.days))

    active_players = create_list(:survival_player, 3, survival_id: survival.uid) do |player|
      player.begin_streak(123)
    end

    create_list(:survival_player, 3, survival_id: survival.uid) do |player|
      game = create(:game, game_mode_id: survival.uid)
      create(:game_player, game: game, wallet_addr: player.wallet_addr)

      player.begin_streak(123)
      player.finish_streak(game.game_id)
    end

    active_players_ids = active_players.map { |p| p.id.to_s }

    subject.call

    expect(Survivals::FinishPlayersStreaksJob).to have_received(:perform_in).with(any_args, active_players_ids).once
  end
end
