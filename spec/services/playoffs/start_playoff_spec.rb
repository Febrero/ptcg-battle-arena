require "rails_helper"

RSpec.describe Playoffs::StartPlayoff, type: :service do
  describe "#call" do
    let!(:ticket) { create(:ticket) }
    let!(:playoff) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], state: "opened") }
    let!(:teams) { create_list(:playoffs_team, 8, playoff: playoff, ticket_id: ticket.bc_ticket_id.to_s) }
    let(:playoff_uid) { playoff.uid }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Playoffs::Notificator).to receive(:call)
    end

    context "when the playoff exists and can be started" do
      before do
        allow(Playoff).to receive(:find_by).with(uid: playoff_uid).and_return(playoff)
        allow(playoff).to receive(:start!).and_return(true)
      end

      it "starts the playoff, calculates prize pool, and notifies" do
        expect(Rails.logger).to receive(:info).with("Going to start playoff ##{playoff_uid}")
        expect(playoff).to receive(:start!).and_return(true)

        expect(Playoffs::Notificator).to receive(:call).with(playoff_uid, Playoffs::Notificator::TYPE_STATE)

        Playoffs::StartPlayoff.call(playoff_uid)
      end
    end

    context "when the playoff does not exist" do
      it "raise exception document not found" do
        expect(Rails.logger).to receive(:info).with("Going to start playoff #-10")

        expect {
          Playoffs::StartPlayoff.call(-10)
        }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when the playoff cannot be started" do
      before do
        allow(Playoff).to receive(:find_by).with(uid: playoff_uid).and_return(playoff)
        allow(playoff).to receive(:start!).and_return(false)
      end

      it "does not calculate prize pool or notify" do
        expect(Rails.logger).to receive(:info).with("Going to start playoff ##{playoff_uid}")

        expect(playoff).to receive(:start!).and_return(false)
        expect(playoff).not_to receive(:reload)

        expect(Playoffs::Notificator).not_to receive(:call)

        Playoffs::StartPlayoff.call(playoff_uid)
      end
    end
  end
end
