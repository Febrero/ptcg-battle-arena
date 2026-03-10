require "rails_helper"

RSpec.describe Events::SmartContracts::TicketFactory::Process do
  it "calls the correct service based on event name (buy ticket)" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Events::SmartContracts::TicketFactory::BuyTicket).to receive(:call)
    described_class.call({event_name: "BuyTicket"}.stringify_keys)
    expect(Events::SmartContracts::TicketFactory::BuyTicket).to have_received(:call)
  end

  it "calls the correct service based on event name (transfer single)" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Events::SmartContracts::TicketFactory::TransferSingle).to receive(:call)
    described_class.call({event_name: "TransferSingle"}.stringify_keys)
    expect(Events::SmartContracts::TicketFactory::TransferSingle).to have_received(:call)
  end

  it "calls the correct service based on event name (transfer batch)" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Events::SmartContracts::TicketFactory::TransferBatch).to receive(:call)
    described_class.call({event_name: "TransferBatch"}.stringify_keys)
    expect(Events::SmartContracts::TicketFactory::TransferBatch).to have_received(:call)
  end

  it "logs not implemented message if event handler is not defined" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Rails.logger).to receive(:info)
    described_class.call({event_name: "FAKE EVENT NAME"}.stringify_keys)
    expect(Rails.logger).to have_received(:info).with("Event handler not implemented")
  end

  it "does not call the event handler if the transaction is invalid" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(false)
    expect(Events::SmartContracts::TicketFactory::BuyTicket).not_to receive(:call)
    expect(Events::SmartContracts::TicketFactory::TransferSingle).not_to receive(:call)
    expect(Events::SmartContracts::TicketFactory::TransferBatch).not_to receive(:call)
    expect(Rails.logger).not_to receive(:info)
  end
end
