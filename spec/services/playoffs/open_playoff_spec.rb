require "rails_helper"

RSpec.describe Playoffs::OpenPlayoff, type: :service do
  describe "#call" do
    let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
    let!(:playoff1) { create(:playoff, state: "upcoming", open_date: 1.hour.ago) }
    let!(:playoff2) { create(:playoff, state: "upcoming", open_date: 1.hour.ago) }
    let!(:playoff3) { create(:playoff, state: "upcoming", open_date: 1.week.from_now) }

    it "opens the playoffs with open date in the past" do
      # expect(Rails.logger).to receive(:info).with("Going to open playoffs")
      allow(Playoffs::Notificator).to receive(:call)
      expect {
        Playoffs::OpenPlayoff.call
      }.to change { playoff1.reload.state }.from("upcoming").to("opened")

      expect(playoff2.reload.state).to eq("opened")
      expect(playoff3.reload.state).to eq("upcoming")
    end

    it "does not open playoffs with open date in the future" do
      # expect(Rails.logger).to receive(:info).with("Going to open playoffs")
      allow(Playoffs::Notificator).to receive(:call)
      expect {
        Playoffs::OpenPlayoff.call
      }.not_to change { playoff3.reload.state }

      expect(playoff1.reload.state).to eq("opened")
      expect(playoff2.reload.state).to eq("opened")
    end
  end
end
