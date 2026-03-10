require "rails_helper"

RSpec.describe Events::SmartContracts::Opener::Process do
  it "calls the correct service based on event name (transfer)" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Events::SmartContracts::Opener::Transfer).to receive(:call)
    described_class.call({event_name: "Transfer"}.stringify_keys)
    expect(Events::SmartContracts::Opener::Transfer).to have_received(:call)
  end

  it "logs not implemented message if event handler is not defined" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(true)
    allow(Rails.logger).to receive(:info)
    described_class.call({event_name: "FAKE EVENT NAME"}.stringify_keys)
    expect(Rails.logger).to have_received(:info).with("Event handler not implemented")
  end

  it "does not call the event handler if the transaction is invalid" do
    allow(Events::SmartContracts::ValidateTransaction).to receive(:call).and_return(false)
    expect(Events::SmartContracts::Opener::Transfer).not_to receive(:call)
    expect(Rails.logger).not_to receive(:info)
  end
end
