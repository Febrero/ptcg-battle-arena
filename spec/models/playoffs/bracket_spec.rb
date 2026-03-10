require "rails_helper"

RSpec.describe Playoffs::Bracket, type: :model do
  describe "fields" do
    it { should have_field(:current_bracket).of_type(Integer) }
    it { should have_field(:next_bracket).of_type(Integer) }
    it { should have_field(:next_bracket_id).of_type(String) }
    it { should have_field(:round).of_type(Integer) }
    it { should have_field(:teams_ids).of_type(Array).with_default_value_of([]) }
  end

  describe "associations" do
    it { should belong_to(:playoff) }
  end

  describe "indexes" do
    it { should have_index_for(playoff_id: 1).with_options(name: "playoff_id_index", background: true) }
    it { should have_index_for(round: 1).with_options(name: "round_index", background: true) }
  end

  describe "#teams" do
    let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
    let(:team1) { create(:playoffs_team) }
    let(:team2) { create(:playoffs_team) }
    let(:bracket) { create(:playoffs_bracket, teams_ids: [team1.id, team2.id]) }

    it "returns an array of teams" do
      teams = bracket.teams
      expect(teams).to be_an(Array)
      expect(teams.size).to eq(2)
      expect(teams).to include(team1, team2)
    end
  end
end
