require "rails_helper"

RSpec.describe Playoffs::Team, type: :model do
  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let!(:playoff) { create(:playoff) }
  describe "fields" do
    it { should have_field(:wallet_addr).of_type(String) }
    it { should have_field(:wallet_addr_downcased).of_type(String) }
    it { should have_field(:profile_id).of_type(String) }
    it { should have_field(:current_bracket_id).of_type(String) }
    it { should have_field(:ticket_id).of_type(String) }
    it { should have_field(:ticket_amount).of_type(Integer).with_default_value_of(1) }
  end

  describe "associations" do
    it { should belong_to(:playoff) }
  end

  describe "validations" do
    subject { Playoffs::Team.new(wallet_addr_downcased: "wallet_address", playoff_id: "playoff_id") }

    it "config wallet_addr" do
      should validate_uniqueness_of(:wallet_addr_downcased).scoped_to(:playoff_id)
    end

    it "check wallet_addr uniqueness exception" do
      Playoffs::Team.create!(wallet_addr_downcased: "wallet_address", playoff: playoff)
      expect { Playoffs::Team.create!(wallet_addr_downcased: "wallet_address", playoff: playoff) }.to raise_error(Mongoid::Errors::Validations)
    end
  end

  describe "indexes" do
    it { should have_index_for(playoff_id: 1).with_options(name: "playoff_id_index", background: true) }
    it { should have_index_for(wallet_addr: 1).with_options(name: "wallet_addr_index", background: true) }
    it { should have_index_for(wallet_addr_downcased: 1).with_options(name: "wallet_addr_downcased_index", background: true) }
    it { should have_index_for(current_bracket_id: 1).with_options(name: "current_bracket_id_index", background: true) }
  end

  describe "#current_bracket" do
    let!(:team) { Playoffs::Team.create(current_bracket_id: "bracket_id", playoff: playoff) }
    let(:bracket) { instance_double("Playoffs::Bracket") }

    before do
      allow(playoff).to receive_message_chain(:brackets, :find).with("bracket_id").and_return(bracket)
    end

    context "when current_bracket_id is present" do
      it "returns the current bracket for the team's playoff" do
        expect(team.current_bracket).to eq(bracket)
      end
    end

    context "when current_bracket_id is nil" do
      before do
        allow(team).to receive(:current_bracket_id).and_return(nil)
      end

      it "returns nil" do
        expect(team.current_bracket).to be_nil
      end
    end
  end
end
