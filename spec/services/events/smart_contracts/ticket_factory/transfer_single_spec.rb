require "rails_helper"

RSpec.describe Events::SmartContracts::TicketFactory::TransferSingle do
  let!(:ticket) { create(:ticket, bc_ticket_id: 2) }
  let!(:ticket_balance1) do
    create(
      :ticket_balance,
      balance: 5,
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket: ticket
    )
  end
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      from: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      to: "0x6c2005f258d8D1EF92D0A1E86b68e884d1805678",
      ticket_id: ticket.bc_ticket_id,
      value: 5,
      contract_address: ticket.ticket_factory_contract_address
    })
  end

  it "decreases tickets from sender balance" do
    described_class.call(event)
    expect(ticket_balance1.reload.balance).to eq(0)
  end

  context "when receiver doesnt have a ticket balance object created" do
    it "creates a ticket balance object for receiver" do
      described_class.call(event)
      expect(TicketBalance.where(bc_ticket_id: ticket_balance1.bc_ticket_id, wallet_addr: event[:to]).count).to eq(1)
    end

    it "increases tickets to receiver balance" do
      described_class.call(event)
      expect(
        TicketBalance.where(
          bc_ticket_id: ticket_balance1.bc_ticket_id,
          wallet_addr: event[:to]
        ).first.balance
      ).to eq(5)
    end
  end

  context "when receiver has a ticket balance object created" do
    let!(:ticket_balance2) do
      create(
        :ticket_balance,
        balance: 0,
        wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1805678",
        ticket: ticket
      )
    end

    it "increases tickets to receiver balance" do
      described_class.call(event)
      expect(ticket_balance2.reload.balance).to eq(5)
    end
  end
end
