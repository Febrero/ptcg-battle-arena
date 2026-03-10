require "rails_helper"
Sidekiq::Testing.fake!
RSpec.describe NftsStatsEventJob, type: :job do
  describe "#perform" do
    let(:json_data) { {"NFTStats" => []} }

    before do
      allow(Events::NftsStats::Process).to receive(:call)
      allow(Rails.logger).to receive(:info)
    end

    it "logs a message indicating the processing of Nfts Stats" do
      expect(Rails.logger).to receive(:info).with("Going to process Nfts Stats (Sidekiq Job)")

      subject.perform(json_data)
    end

    it "calls Events::NftsStats::Process with the JSON data" do
      expect(Events::NftsStats::Process).to receive(:call).with(json_data)

      subject.perform(json_data)
    end
  end
end
