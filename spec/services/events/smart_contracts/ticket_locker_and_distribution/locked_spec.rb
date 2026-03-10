require "rails_helper"

RSpec.describe Events::SmartContracts::TicketLockerAndDistribution::Locked do
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      owner: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket_id: 2,
      amount: 3
    })
  end
  let!(:ticket) { create(:ticket, bc_ticket_id: 2) }
  let!(:ticket_balance) do
    create(
      :ticket_balance,
      balance: 5,
      deposited: 0,
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket: ticket
    )
  end

  before do
    described_class.call(event)
  end

  it "updates the ticket balance" do
    expect(ticket_balance.reload.balance).to eq(2)
  end

  it "updates the ticket deposited" do
    expect(ticket_balance.reload.deposited).to eq(3)
  end
end
