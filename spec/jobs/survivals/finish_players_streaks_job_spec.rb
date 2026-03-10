require "rails_helper"

RSpec.describe Survivals::FinishPlayersStreaksJob, type: :job do
  let(:params) { [1, 2, 3, 4, 5] }

  describe "#perform" do
    before do
      allow(Survivals::FinishPlayersStreaks).to receive(:call).with(params)
      allow(Rails.logger).to receive(:info)
    end

    it "logs a message indicating the processing of the job" do
      expect(Rails.logger).to receive(:info).with("Going to process service for finishing streaks for survival players (Sidekiq Job)")

      subject.perform(params)
    end

    it "calls Survivals::FinishPlayersStreaks" do
      expect(Survivals::FinishPlayersStreaks).to receive(:call).with(params)

      subject.perform(params)
    end
  end
end
