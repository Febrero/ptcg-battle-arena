require "rails_helper"
RSpec.describe Kafka::NftsStatsEventConsumer, type: :consumer do
  describe "message processing" do
    let(:message) { double(value: '{"NFTStats": []}') }
    let(:parsed_message) { {"NFTStats" => []} }

    before do
      allow(Rails.logger).to receive(:info)
      allow(JSON).to receive(:parse).and_return(parsed_message)
      allow(NftsStatsEventJob).to receive(:perform_async)
    end

    it "logs a message indicating the processing of a Nfts Stats event" do
      expect(Rails.logger).to receive(:info).with("Going to process a Nfts Stats event")

      subject.process(message)
    end

    it "parses the message JSON" do
      expect(JSON).to receive(:parse).with(message.value).and_return(parsed_message)

      subject.process(message)
    end

    it "enqueues the NftsStatsEventJob" do
      expect(NftsStatsEventJob).to receive(:perform_async).with(parsed_message)

      subject.process(message)
    end
  end
end
