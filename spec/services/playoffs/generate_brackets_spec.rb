require "rails_helper"

RSpec.describe Playoffs::GenerateBrackets do
  describe "#call" do
    let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
    let!(:playoff) { create(:playoff) }
    let!(:teams) { create_list(:playoffs_team, 16, playoff: playoff) }

    before do
      allow(Rails.logger).to receive(:info)
    end

    it "generates brackets for the playoff and check round number" do
      Playoffs::GenerateBrackets.call(playoff.uid)

      expect(playoff.brackets.first.round).to eq(4)
    end

    context "when the teams count exceeds the tournament limit" do
      let!(:playoff) { create(:playoff) }
      let!(:teams) { create_list(:playoffs_team, 3, playoff: playoff) }

      it "raises an error" do
        stub_const("Playoff::TOTAL_TEAMS_FORMAT", [2])

        expect { Playoffs::GenerateBrackets.call(playoff.uid) }.to raise_error(RuntimeError, "Invalid teams count")
      end
    end
    context "check brackets randomize" do
      let!(:playoff_c) { create(:playoff, max_teams: 16) }
      let!(:team1) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team2) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team3) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team4) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team5) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team6) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team7) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team8) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team9) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team10) { create(:playoffs_team, playoff: playoff_c) }
      let!(:team11) { create(:playoffs_team, playoff: playoff_c) }

      it "check" do
        teams_ids = playoff_c.teams.map { |team| team.id.to_s }

        Playoffs::GenerateBrackets.call(playoff_c.uid)

        bye_slots = playoff_c.brackets.where(round: 1).count { |bracket| bracket.teams_ids.include? nil }
        team_on_first_round = playoff_c.brackets.where(round: 1).map(&:teams_ids).flatten.delete_if(&:nil?).count

        expect(team_on_first_round).to eq(teams_ids.count)
        expect(bye_slots).to eq(5)
      end
    end
  end

  # Additional tests for private methods and specific scenarios can be added as needed
end
