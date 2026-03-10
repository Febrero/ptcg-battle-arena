require "rails_helper"

RSpec.describe Events::SmartContracts::TicketFactory::BuyTicket do
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      ticket_id: 2,
      quantity: 5,
      buyer: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
    })
  end

  let!(:ticket) do
    create(:ticket, bc_ticket_id: 2, ticket_factory_contract_address: "0x12345")
  end

  let!(:ticket_lisbon) do
    create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x12345")
  end

  let!(:ticket_balance) do
    create(
      :ticket_balance,
      balance: 5,
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket: ticket
    )
  end

  it "updates the ticket balance" do
    event = ActiveSupport::HashWithIndifferentAccess.new({
      ticket_id: 2,
      quantity: 5,
      contract_address: "0x12345",
      buyer: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
    })
    described_class.call(event)

    expect(ticket_balance.reload.balance).to eq(10)
  end

  it "creates a new ticket balance" do
    event = ActiveSupport::HashWithIndifferentAccess.new({
      ticket_id: 1,
      quantity: 3,
      contract_address: "0x12345",
      buyer: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2"
    })
    described_class.call(event)
    tb = TicketBalance.where(
      bc_ticket_id: event[:ticket_id],
      ticket_factory_contract_address: event[:contract_address],
      wallet_addr: event[:buyer]
    ).first

    expect(tb.balance).to eq(3)
  end
end
