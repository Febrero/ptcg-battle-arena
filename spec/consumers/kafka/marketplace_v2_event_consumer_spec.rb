require "rails_helper"

RSpec.describe Kafka::MarketplaceV2EventConsumer do
  describe "#process" do
    let(:consumer) { Kafka::MarketplaceV2EventConsumer.new }

    it "logs a message and enqueues a job" do
      message = double("message", value: '{ "id": 123 }')
      allow(MarketplaceV2EventJob).to receive(:perform_async)

      expect(Rails.logger).to receive(:info).with("Going to process a marketplace v2 event")
      expect(JSON).to receive(:parse).with(message.value).and_return({"id" => 123})
      expect(MarketplaceV2EventJob).to receive(:perform_async).with({"id" => 123})

      consumer.process(message)
    end
  end
end
