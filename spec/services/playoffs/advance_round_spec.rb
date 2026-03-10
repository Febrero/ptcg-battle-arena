require "rails_helper"

RSpec.describe Playoffs::AdvanceRound do
  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let(:playoff) { create(:playoff, :with_teams, teams_count: 7) }

  before do
    allow(Playoffs::AdvanceRoundJob).to receive(:perform_in)
    allow(Playoffs::Notificator).to receive(:call)
    # this flow here is needed for correctly validating the advance_round_job
    # call (it is also done on the start event)
    playoff.update_attributes(state: "ongoing")

    playoff.send(:validate_number_of_teams)
    playoff.send(:generate_brackets)
    playoff.send(:generate_rounds)
  end

  describe "#call" do
    context "when not all games of a round are played" do
      it "should selected team registered first in playoff" do
        # expect { Playoffs::AdvanceRound.call(playoff.uid) }.to raise_error(Playoffs::MissingGameForRoundAdvance)
      end
    end

    context "when all games of a round are played" do
      before do
        playoff.brackets.update_all(winner_team_id: "xpto")
      end

      describe "if the round is the last one" do
        before do
          playoff.update_attributes(current_round: playoff.rounds.count)
        end

        it "should not increment current_round on the playoff" do
          puts "#{playoff.rounds.count} > #{playoff.current_round}: #{playoff.rounds.count > playoff.current_round}"
          expect {
            Playoffs::AdvanceRound.call(playoff.uid)
          }.to_not change {
            playoff.reload.current_round
          }
        end

        it "should not schedule a new advance round" do
          puts "#{playoff.rounds.count} > #{playoff.current_round}: #{playoff.rounds.count > playoff.current_round}"
          Playoffs::AdvanceRound.call(playoff.uid)

          expect(Playoffs::AdvanceRoundJob).not_to have_received(:perform_in).with(any_args)
        end
      end

      describe "if the round is not the last one" do
        it "should increment current_round on the playoff" do
          expect {
            Playoffs::AdvanceRound.call(playoff.uid)
          }.to change {
            playoff.reload.current_round
          }.by(1)
        end

        it "should schedule a new advance round" do
          Playoffs::AdvanceRound.call(playoff.uid)

          next_round_timeframe = playoff.rounds.where(number: playoff.reload.current_round).first.duration

          expect(Playoffs::AdvanceRoundJob).to have_received(:perform_in).with(next_round_timeframe.minutes, playoff.uid).once
        end
      end
    end
  end
end
