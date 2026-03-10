require "rails_helper"

RSpec.describe Kafka::MarketplaceEventConsumer do
  describe "#process" do
    let(:consumer) { Kafka::MarketplaceEventConsumer.new }

    it "logs a message and enqueues a job" do
      message = double("message", value: '{ "id": 123 }')
      allow(MarketplaceEventJob).to receive(:perform_async)

      expect(Rails.logger).to receive(:info).with("Going to process a marketplace event")
      expect(JSON).to receive(:parse).with(message.value).and_return({"id" => 123})
      expect(MarketplaceEventJob).to receive(:perform_async).with({"id" => 123})

      consumer.process(message)
    end
  end
end
