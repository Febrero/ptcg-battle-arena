require "rails_helper"
require "support/playoffs_helper"

RSpec.describe Playoffs::RegisterPrizeOnTeamAndSendToLeaderboards do
  include PlayoffsHelper

  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let!(:first_playoff) { create(:playoff, :with_teams, teams_count: 16) }
  let!(:second_playoff) {
    create(:playoff, :with_teams, teams_count: 7) do |pl|
      first_team_of_first_playoff = first_playoff.teams.first
      create(:playoffs_team, wallet_addr: first_team_of_first_playoff.wallet_addr, playoff: pl)
    end
  }

  before do
    Playoffs::GenerateBrackets.call(first_playoff.uid)
    Playoffs::GenerateRounds.call(first_playoff.uid)
    Playoffs::GenerateBrackets.call(second_playoff.uid)
    Playoffs::GenerateRounds.call(second_playoff.uid)
    allow(Playoffs::SendEndPlayoffEventToLeaderboards).to receive(:call)
  end

  it "sends end playoff event to leaderboards" do
    simulate(first_playoff.uid)
    subject.call(first_playoff.uid)

    expect(
      Playoffs::SendEndPlayoffEventToLeaderboards
    ).to have_received(:call).exactly(first_playoff.teams.count)
  end

  context "when team wins" do
    it "increments the team prize sequence" do
      first_playoff_winner_team = first_playoff.teams.first
      simulate(first_playoff.uid, true, first_playoff_winner_team.id)

      expect {
        subject.call(first_playoff.uid)
      }.to change { first_playoff_winner_team.reload.prize_sequence }.by(1)
      expect(first_playoff_winner_team.prize_sequence).to eq(1)

      second_playoff_winner_team = second_playoff.teams.last
      simulate(second_playoff.uid, true, second_playoff_winner_team.id)

      expect {
        subject.call(second_playoff.uid)
      }.to change { second_playoff_winner_team.reload.prize_sequence }.by(2)
      expect(second_playoff_winner_team.prize_sequence).to eq(2)
    end
  end

  context "when the team loses" do
    before do
      simulate(first_playoff.uid, true, first_playoff.teams.first.id)
      subject.call(first_playoff.uid)
    end

    it "resets the team prize sequence to 0" do
      second_playoff_winner_team = second_playoff.teams.last
      simulate(second_playoff.uid, true, second_playoff_winner_team.id, false)
      subject.call(second_playoff.uid)

      expect(second_playoff_winner_team.reload.prize_sequence).to eq(0)
    end
  end
end
