require "rails_helper"

RSpec.describe Survivals::ProcessGame do
  let!(:season) { create(:season) }
  let(:survival) { create(:survival, levels_count: 3) }

  before do
    allow(Survivals::CalculatePrizeValue).to receive(:call)
    allow(Survivals::GeneratePrize).to receive(:call)
    allow(Survivals::SendStreakEventToKafka).to receive(:call)

    create_list(:game, 2, game_mode_id: survival.uid) do |game|
      create_list(:game_player, 2, game: game).each do |player|
        survival_player = create(:survival_player, survival: survival, wallet_addr: player.wallet_addr, entries: [])
        survival_player.begin_streak(12345)

        survival_player.update_current_streak_level(game.game_id)
        survival_player.update_current_streak_level(game.game_id)
      end
    end
  end

  context "finishing streak" do
    it "ends a streak with wins only" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      expect {
        subject.call(game, game.to_original_request)
      }.to change {
        winner.reload.active_entry_id
      }.from(String).to(nil)
    end

    it "ends a streak when loses" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      expect {
        subject.call(game, game.to_original_request)
      }.to change {
        loser.reload.active_entry_id
      }.from(String).to(nil)
    end

    it "ends a streak when the survival is already closed" do
      survival.update_attributes(levels_count: 10)

      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      expect {
        survival.update_attributes(state: "closed")
        subject.call(game, game.to_original_request)
      }.to change {
        winner.reload.active_entry_id
      }.from(String).to(nil)
    end

    it "only updates the level info for an entry, when a user wins (doesn't finish streak)" do
      survival.update_attributes(levels_count: 10)

      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      expect {
        subject.call(game, game.to_original_request)
      }.to change {
        winner.reload.active_entry.levels_completed
      }.by(1)
    end
  end

  context "calculating prizes info" do
    it "generates for a player that wins the last level game" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::CalculatePrizeValue).to have_received(:call).with(any_args, winner.wallet_addr).once
    end

    it "generates ticket key to leaderboards" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      winner.finish_streak
      winner.begin_streak(1234)

      game_details = game.to_original_request
      subject.call(game, game_details)

      expect(game_details["Players"][0]).to include("EntryCount" => 1)
    end

    it "generates for a player that loses a game (that was not the first one)" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::CalculatePrizeValue).to have_received(:call).with(any_args, loser.wallet_addr).once
    end

    it "generates for a player that loses on the first game" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      loser.current_entry.update_attributes(levels_completed: 0)

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::CalculatePrizeValue).to have_received(:call).with(any_args, loser.wallet_addr).once
    end
  end

  context "generating prizes" do
    it "generates for a player that wins the last level game" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::GeneratePrize).to have_received(:call).with(any_args, winner, game.game_id).once
    end

    it "generates for a player that loses a game (that was not the first one)" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::GeneratePrize).to have_received(:call).with(any_args, loser, game.game_id).once
    end

    it "generates for a player that loses on the first game" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      loser.current_entry.update_attributes(levels_completed: 0)

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      subject.call(game, game.to_original_request)

      expect(Survivals::GeneratePrize).to have_received(:call).with(any_args, loser, game.game_id).once
    end

    it "should rescue Survivals::GameAlreadyProcessed exception" do
      allow(Airbrake).to receive(:notify)

      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      winner.games_on_survival << game.game_id
      winner.save

      subject.call(game, game.to_original_request)

      expect(Airbrake).to have_received(:notify).once
    end

    it "should re-raise any exception raised (except Survivals::GameAlreadyProcessed)" do
      winner, loser = SurvivalPlayer.where(survival_id: survival.uid).all.to_a

      game = create(:game, game_mode_id: survival.uid) do |game|
        create(:game_player, game: game, winner: true, wallet_addr: winner.wallet_addr)
        create(:game_player, game: game, winner: false, wallet_addr: loser.wallet_addr)
      end

      winner.games_on_survival = nil
      winner.save

      expect { subject.call(game, game.to_original_request) }.to raise_error(StandardError)
    end
  end
end
