require "rails_helper"

RSpec.describe Survivals::GeneratePlayer do
  let!(:survival) { create(:survival) }
  let(:wallet_addr) { "0x1234567" }
  let!(:ticket) { create(:ticket) }

  before do
    # 	create(:ticket_balance, ticket: ticket, wallet_addr: wallet_addr, bc_ticket_id: ticket.bc_ticket_id, balance: 10)
    allow(SpendTickets).to receive(:call).and_return(true)
  end

  it "should create a survival player with correct arguments" do
    expect {
      subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)
    }.to change {
      SurvivalPlayer.count
    }.by(1)
  end

  it "should not create a new player if one already exists with that wallet_addr and survival_uid" do
    expect {
      create(:survival_player, survival_id: survival.uid, wallet_addr: wallet_addr)

      subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)
    }.to change {
      SurvivalPlayer.count
    }.by(1)
  end

  it "should create a player with an active entry with the ticket_id" do
    survival_player = subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)

    expect(survival_player.active_entry.ticket_id).to eq(ticket.bc_ticket_id)
  end

  it "should have only one entry when player is created" do
    survival_player = subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)

    expect(survival_player.entries.count).to eq(1)
  end

  it "should create a new entry" do
    survival_player = create(:survival_player, survival_id: survival.uid, wallet_addr: wallet_addr)

    expect {
      subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)
    }.to change {
      survival_player.reload.entries.count
    }.by(1)
  end

  it "should raise an exception when creating a player without wallet_addr" do
    expect { subject.call(nil, survival.uid, ticket.bc_ticket_id) }.to raise_error(Survivals::PlayerFieldsMissing)
  end

  it "should raise an exception when creating a player without survival_uid" do
    expect { subject.call(wallet_addr, nil, ticket.bc_ticket_id) }.to raise_error(Survivals::PlayerFieldsMissing)
  end

  it "should raise an exception when creating a player with an invalid survival_uid" do
    survival_uid = survival.uid + 1

    expect { subject.call(wallet_addr, survival_uid, ticket.bc_ticket_id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

  it "should raise an exception when creating a player without ticket_id" do
    expect { subject.call(wallet_addr, survival.uid, nil) }.to raise_error(Survivals::PlayerFieldsMissing)
  end

  it "should raise an exception when trying to create a streak without ticket balances" do
    allow(SpendTickets).to receive(:call).and_return(false)

    expect { subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id) }.to raise_error(Survivals::TicketNotSpent)
  end

  it "should raise an exception when trying to create a streak without ticket balance" do
    allow(SpendTickets).to receive(:call).and_return(false)

    expect { subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id) }.to raise_error(Survivals::TicketNotSpent)
  end

  it "should not create a new entry if the user doesn't hae ticket balance" do
    allow(SpendTickets).to receive(:call).and_return(false)

    survival_player = create(:survival_player, survival_id: survival.uid, wallet_addr: wallet_addr)

    expect {
      begin
        subject.call(wallet_addr, survival.uid, ticket.bc_ticket_id)
      rescue
        nil
      end
    }.to change {
      survival_player.entries.count
    }.by(0)
  end
end
