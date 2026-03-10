require "rails_helper"

RSpec.describe TicketBalance, type: :model do
  subject(:ticket_balance) { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:wallet_addr) }
    it { is_expected.to validate_presence_of(:balance) }
    it { is_expected.to validate_presence_of(:deposited) }
    it { is_expected.to validate_uniqueness_of(:bc_ticket_id).scoped_to([:wallet_addr, :ticket_factory_contract_address]) }
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "wallet_addr_index", background: true) }
    it { is_expected.to have_index_for(bc_ticket_id: 1).with_options(name: "bc_ticket_id_index", background: true) }
    it { is_expected.to have_index_for(wallet_addr: 1, bc_ticket_id: 1, ticket_factory_contract_address: 1).with_options(unique: true, name: "wallet_addr_bc_ticket_id_ticket_factory_contract_address_index", background: true) }
  end

  describe "callbacks" do
    it "denormalizes ticket data on ticket balance creation" do
      ticket = create(
        :ticket,
        bc_ticket_id: 199,
        ticket_factory_contract_address: "0xlalala",
        ticket_locker_and_distribution_contract_address: "0xlelele"
      )
      ticket_balance = create(:ticket_balance, ticket: ticket)
      expect(ticket_balance.bc_ticket_id).to eq(199)
      expect(ticket_balance.ticket_factory_contract_address).to eq("0xlalala")
      expect(ticket_balance.ticket_locker_and_distribution_contract_address).to eq("0xlelele")
    end

    it "denormalizes ticket data on ticket update" do
      ticket = create(
        :ticket,
        bc_ticket_id: 199,
        ticket_factory_contract_address: "0xlalala",
        ticket_locker_and_distribution_contract_address: "0xlelele"
      )
      ticket_balance = create(:ticket_balance, ticket: ticket)
      ticket.update(
        bc_ticket_id: 100,
        ticket_factory_contract_address: "0xloko",
        ticket_locker_and_distribution_contract_address: "0xloka"
      )
      expect(ticket_balance.reload.bc_ticket_id).to eq(100)
      expect(ticket_balance.reload.ticket_factory_contract_address).to eq("0xloko")
      expect(ticket_balance.reload.ticket_locker_and_distribution_contract_address).to eq("0xloka")
    end
  end
end
