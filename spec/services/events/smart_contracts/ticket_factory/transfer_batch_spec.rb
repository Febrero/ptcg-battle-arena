require "rails_helper"

RSpec.describe Events::SmartContracts::TicketFactory::TransferBatch do
  let!(:ticket2) { create(:ticket, bc_ticket_id: 2, ticket_factory_contract_address: "0x99") }
  let!(:ticket3) { create(:ticket, bc_ticket_id: 3, ticket_factory_contract_address: "0x99") }
  let!(:ticket_balance_2_sender) do
    create(
      :ticket_balance,
      balance: 10,
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket: ticket2
    )
  end
  let!(:ticket_balance_3_sender) do
    create(
      :ticket_balance,
      balance: 10,
      wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      ticket: ticket3
    )
  end
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      from: "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2",
      to: "0x6c2005f258d8D1EF92D0A1E86b68e884d1805678",
      ticket_ids: [2, 3],
      values: [5, 4],
      contract_address: ticket2.ticket_factory_contract_address
    })
  end

  it "decreases tickets 2 from ticket balance" do
    described_class.call(event)
    expect(ticket_balance_2_sender.reload.balance).to eq(5)
  end

  it "decreases tickets 3 from ticket balance" do
    described_class.call(event)
    expect(ticket_balance_3_sender.reload.balance).to eq(6)
  end

  context "when receiver doesnt have a ticket balance object created" do
    it "creates a ticket 2 balance object for receiver" do
      described_class.call(event)
      expect(TicketBalance.where(bc_ticket_id: event["ticket_ids"][0], wallet_addr: event[:to]).count).to eq(1)
    end

    it "creates a ticket 3 balance object for receiver" do
      described_class.call(event)
      expect(TicketBalance.where(bc_ticket_id: event["ticket_ids"][1], wallet_addr: event[:to]).count).to eq(1)
    end

    it "increases tickets 2 to receiver balance" do
      described_class.call(event)
      expect(
        TicketBalance.where(bc_ticket_id: event["ticket_ids"][0], wallet_addr: event[:to]).first.balance
      ).to eq(5)
    end

    it "increases tickets 3 to receiver balance" do
      described_class.call(event)
      expect(
        TicketBalance.where(bc_ticket_id: event["ticket_ids"][1], wallet_addr: event[:to]).first.balance
      ).to eq(4)
    end
  end

  context "when receiver has a ticket balance object created" do
    let!(:ticket_balance_2_receiver) do
      create(:ticket_balance,
        balance: 0,
        wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1805678",
        ticket: ticket2)
    end
    let!(:ticket_balance_3_receiver) do
      create(
        :ticket_balance,
        balance: 0,
        wallet_addr: "0x6c2005f258d8D1EF92D0A1E86b68e884d1805678",
        ticket: ticket3
      )
    end

    it "increases tickets 2 to receiver balance" do
      described_class.call(event)
      expect(ticket_balance_2_receiver.reload.balance).to eq(5)
    end

    it "increases tickets 3 to receiver balance" do
      described_class.call(event)
      expect(ticket_balance_3_receiver.reload.balance).to eq(4)
    end
  end
end
