require "rails_helper"
require "support/playoffs_helper"

RSpec.describe Playoffs::GeneratePositions do
  include PlayoffsHelper
  let!(:ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let!(:playoff) { create(:playoff, :with_teams, teams_count: 8) }

  before do
    allow(Rabbitmq::PrizesPublisher).to receive(:send)

    Playoffs::GenerateBrackets.call(playoff.uid)
    Playoffs::GenerateRounds.call(playoff.uid)

    # override the teams in brackets so we can predetermine the final positions
    playoff.brackets.select { |b| b.round == 1 }.each_with_index do |b, idx|
      team1 = playoff.teams[idx * 2]
      team2 = playoff.teams[idx * 2 + 1]

      b.teams_ids = [team1.id.to_s, team2.id.to_s]
      b.save
    end

    simulate(playoff.uid, false)
    Playoffs::GeneratePrizes.call(playoff.uid)
  end

  it "generate positions correctly" do
    Playoffs::GeneratePositions.new(playoff.uid).call
    predetermined_positions = [1, 5, 3, 7, 2, 6, 4, 8]
    final_positions = playoff.reload.teams.map { |t| t.position }

    expect(final_positions).to eq(predetermined_positions)
  end
end
