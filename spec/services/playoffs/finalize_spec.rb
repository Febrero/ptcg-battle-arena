require "rails_helper"
RSpec.describe Playoffs::Finalize do
  describe "#call" do
    let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
    let(:playoff) { create(:playoff, state: "ongoing") }
    let(:winner_team_id) { "1" }

    before do
      allow(Playoff).to receive(:find_by).with(uid: playoff.uid).and_return(playoff)
      allow(playoff).to receive(:finish!).and_return(true)
      allow(playoff).to receive(:pending!).and_return(true)
      allow(Playoffs::Notificator).to receive(:call)
    end

    it "closes the playoff and marks the winner team" do
      subject.call(playoff.uid, winner_team_id)

      expect(playoff.winner_team_id).to eq(winner_team_id)
      expect(playoff).to have_received(:finish!)
      expect(Playoffs::Notificator).to have_received(:call).with(playoff.uid, Playoffs::Notificator::TYPE_STATE)
    end

    context "when winner_team_id is not provided" do
      let(:winner_team_id) { nil }

      it "does not update the winner team" do
        subject.call(playoff.uid, winner_team_id)

        expect(playoff.winner_team_id).to be_nil
        expect(playoff).to have_received(:pending!)
        expect(Playoffs::Notificator).to have_received(:call).with(playoff.uid, Playoffs::Notificator::TYPE_STATE)
      end
    end

    context "when playoff finish fails" do
      before do
        allow(playoff).to receive(:finish!).and_return(false)
      end

      it "does not send the notification" do
        subject.call(playoff.uid, winner_team_id)

        expect(playoff).to have_received(:finish!)
      end
    end
  end
end
