require "rails_helper"

RSpec.describe Kafka::TicketFactoryEventConsumer do
  describe "#process" do
    let(:consumer) { Kafka::TicketFactoryEventConsumer.new }

    it "logs a message and enqueues a job" do
      message = double("message", value: '{ "id": 123 }')
      allow(TicketFactoryEventJob).to receive(:perform_async)

      expect(Rails.logger).to receive(:info).with("Going to process a ticket factory event")
      expect(JSON).to receive(:parse).with(message.value).and_return({"id" => 123})
      expect(TicketFactoryEventJob).to receive(:perform_async).with({"id" => 123})

      consumer.process(message)
    end
  end
end
