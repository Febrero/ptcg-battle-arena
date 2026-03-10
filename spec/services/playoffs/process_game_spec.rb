require "rails_helper"

RSpec.describe Playoffs::ProcessGame, type: :service do
  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let!(:playoff) { create(:playoff) }
  let!(:game) { create(:game, game_mode_id: playoff.uid) }
  let!(:game_playoff_not_exist) { create(:game, game_mode_id: 10) }
  let!(:teams) { create_list(:playoffs_team, 8, playoff: playoff) }

  let!(:generate_brackets) { Playoffs::GenerateBrackets.call(playoff.uid) }
  let!(:generate_rounds) { Playoffs::GenerateRounds.call(playoff.uid) }
  let(:current_bracket) { Playoffs::Bracket.where(current_bracket: 1).first }
  let(:team1) {
    Playoffs::Team.find(current_bracket.teams_ids[0])
  }
  let(:team2) { Playoffs::Team.find(current_bracket.teams_ids[1]) }
  let(:next_bracket) { Playoffs::Bracket.where(current_bracket: current_bracket.next_bracket).first }
  let(:game_details) {
    {
      "CurrentBracketId" => 1,
      "Players" => [
        {"WalletAddr" => team2.wallet_addr, "GoalsScored" => 1},
        {"WalletAddr" => team1.wallet_addr, "GoalsScored" => 2}
      ]
    }
  }
  let(:winner_team) { team1 }
  before do
    allow(Playoffs::Notificator).to receive(:call)
    allow(Playoffs::Finalize).to receive(:call)
    allow_any_instance_of(Playoffs::ProcessGame).to receive(:get_winner_team).and_return(winner_team)
    allow_any_instance_of(Playoffs::ProcessGame).to receive(:get_current_bracket).and_return(current_bracket)
    allow_any_instance_of(Playoffs::ProcessGame).to receive(:get_next_bracket).and_return(next_bracket)
  end

  describe "#call" do
    it "processes the game and updates bracket info" do
      expect(Rails.logger).to receive(:info).with("Custom processing for Playoff GAME: #{game.game_id}\n\Playoff: #{game.game_mode_id} Bracket: #{game_details["CurrentBracketId"]}")

      expect {
        Playoffs::ProcessGame.call(game, game_details)
      }.to change { current_bracket.reload.winner_team_id }.to(winner_team.id.to_s)
        .and change { current_bracket.reload.game_id }.to(game.game_id)
        .and change { current_bracket.reload.goals_scored }.to([2, 1])
        .and change { next_bracket.reload.teams_ids }.to([nil, winner_team.id.to_s])

      expect(Playoffs::Notificator).to have_received(:call).with(
        playoff.uid,
        Playoffs::Notificator::TYPE_PROCESS_GAME,
        {
          current_bracket: current_bracket.current_bracket,
          winner_team_id: winner_team.id.to_s,
          winner_team_wallet: winner_team.wallet_addr_downcased,
          game_id: game.game_id
        }
      )

      expect(Playoffs::Finalize).not_to have_received(:call)
    end

    it "calls FinalizePlayoff when current bracket winner is selected by system and no next bracket exists" do
      allow_any_instance_of(Playoffs::ProcessGame).to receive(:get_next_bracket).and_return(nil)

      expect {
        Playoffs::ProcessGame.call(game, game_details)
      }.to change { current_bracket.reload.winner_team_id }.to(winner_team.id.to_s)

      expect(Playoffs::Notificator).to have_received(:call).with(
        playoff.uid,
        Playoffs::Notificator::TYPE_PROCESS_GAME,
        {
          current_bracket: current_bracket.current_bracket,
          winner_team_id: winner_team.id.to_s,
          winner_team_wallet: winner_team.wallet_addr_downcased,
          game_id: game.game_id
        }
      )

      expect(Playoffs::Finalize).to have_received(:call).with(playoff.uid, winner_team.id.to_s)
    end

    it "raises an error if the playoff does not exist" do
      expect {
        Playoffs::ProcessGame.call(game_playoff_not_exist, game_details)
      }.to raise_error("Playoff doesn't exist")
    end
  end
end
