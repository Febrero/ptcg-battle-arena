require "rails_helper"

RSpec.describe Survivals::OpenSurvivalJob, type: :job do
  describe "#perform" do
    before do
      allow(Survivals::OpenSurvival).to receive(:call)
      allow(Rails.logger).to receive(:info)
    end

    it "logs a message indicating the processing of the job" do
      expect(Rails.logger).to receive(:info).with("Going to process service for opening incoming survivals (Sidekiq Job)")

      subject.perform
    end

    it "calls Survivals::OpenSurvival" do
      expect(Survivals::OpenSurvival).to receive(:call)

      subject.perform
    end
  end
end
