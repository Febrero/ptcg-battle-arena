require "rails_helper"

RSpec.describe Events::SmartContracts::ValidateTransaction do
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      tx_hash: "0xa097cd1f143be9291b6c2c9f314ba0c997f7754007541112691acbaa1cc6bc1e",
      log_index: 1
    })
  end

  context "when event transaction was already created" do
    before do
      create(:event_transaction, tx_hash: event[:tx_hash], log_index: event[:log_index])
    end

    it "returns false" do
      expect(described_class.call(event)).to be_falsey
    end
  end

  context "when event transaction was not created" do
    it "returns true" do
      expect(described_class.call(event)).to be_truthy
    end

    it "creates event transaction" do
      expect { described_class.call(event) }.to change { EventTransaction.count }.by(1)
    end
  end
end
