require "rails_helper"

RSpec.describe Survivals::CloseExpiredJob, type: :job do
  describe "#perform" do
    before do
      allow(Survivals::CloseExpired).to receive(:call)
      allow(Rails.logger).to receive(:info)
    end

    it "logs a message indicating the processing of the job" do
      expect(Rails.logger).to receive(:info).with("Going to process service for closing expired survivals (Sidekiq Job)")

      subject.perform
    end

    it "calls Survivals::CloseExpired" do
      expect(Survivals::CloseExpired).to receive(:call)

      subject.perform
    end
  end
end
