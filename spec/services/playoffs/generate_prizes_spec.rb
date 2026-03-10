require "rails_helper"
require "support/playoffs_helper"
RSpec.describe Playoffs::GeneratePrizes, vcr: true do
  include PlayoffsHelper
  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let!(:playoff) { create(:playoff) }
  let!(:teams) { create_list(:playoffs_team, 8, playoff: playoff) }
  let!(:generate_brackets) { Playoffs::GenerateBrackets.call(playoff.uid) }
  let!(:generate_rounds) { Playoffs::GenerateRounds.call(playoff.uid) }

  let!(:playoff_tickets) { create(:playoff, erc20_name_alt: "TICKETS") }
  let!(:teams_tickets) { create_list(:playoffs_team, 8, playoff: playoff_tickets) }
  let!(:generate_brackets_tickets) { Playoffs::GenerateBrackets.call(playoff_tickets.uid) }
  let!(:generate_rounds_tickets) { Playoffs::GenerateRounds.call(playoff_tickets.uid) }

  describe "#send_prizes" do
    before do
      allow(Rabbitmq::PrizesPublisher).to receive(:send)
    end

    it "sends prizes  for all teams" do
      simulate(playoff.uid)

      prizes = Playoffs::GeneratePrizes.call(playoff.uid)
      expect(prizes.count).to eq(teams.count)
      expect(Rabbitmq::PrizesPublisher).to have_received(:send).exactly(teams.count).times
    end

    it "prizes with reward" do
      simulate(playoff.uid)
      prizes = Playoffs::GeneratePrizes.call(playoff.uid)
      count_prizes_awarded = prizes.count { |prize| prize[:prize_awarded] }
      expect(playoff.prize_config_per_round.count).to eq(count_prizes_awarded)
    end

    it "Winner Prize" do
      simulate(playoff.uid)
      prizes = Playoffs::GeneratePrizes.call(playoff.uid)
      highest_round = playoff.prize_config_per_round.keys.max
      prize_winner = prizes.find { |prize| prize[:playoff_rounds_completed] == highest_round }
      team_winner = playoff.teams.where(wallet_addr_downcased: prize_winner[:wallet_addr].downcase).first
      expect(team_winner.id.to_s).to eq(playoff.reload.winner_team_id)
    end

    it "not generate prizes when erc20 alt name is TICKETS" do
      allow_any_instance_of(Playoffs::GeneratePrizes).to receive(:generate_reward)
      simulate(playoff_tickets.uid)
      Playoffs::GeneratePrizes.call(playoff_tickets.uid)

      expect(Rabbitmq::PrizesPublisher).to have_received(:send).exactly(0).times
    end
  end
end
