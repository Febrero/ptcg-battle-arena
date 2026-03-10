# spec/services/tutorial_progresses/new_step_spec.rb

require "rails_helper"

RSpec.describe TutorialProgresses::NewStep, type: :service do
  describe "#call" do
    context "when the user's tutorial progress exists" do
      let(:wallet_addr) { "example_wallet_address" }
      let(:downcased_wallet_addr) { wallet_addr.downcase }
      let!(:tutorial_progress) { create(:tutorial_progress, wallet_addr: wallet_addr, wallet_addr_downcased: downcased_wallet_addr) }

      context "when the step is not completed" do
        let(:step_name) { "onboard_screens" }

        it "adds the step to tutorial progress and saves it" do
          result = described_class.call(wallet_addr, step_name)
          expect(result.steps.last.name).to eq(step_name)
          expect(result.completed).to be_falsey
        end
      end

      context "when the step is already completed" do
        let(:step_name) { "onboard_screens" }

        before do
          tutorial_progress.steps.create(name: step_name)
        end

        it "does not add the step again" do
          expect {
            described_class.call(wallet_addr, step_name)
          }.not_to change { tutorial_progress.steps.count }
        end
      end

      context "when the tutorial is completed" do
        it "marks the tutorial as completed" do
          TutorialProgress::STEPS.each do |step_name|
            described_class.call(wallet_addr, step_name)
          end
          expect(tutorial_progress.reload.completed).to be_truthy
        end
      end
    end

    context "when the user's tutorial progress does not exist" do
      let(:wallet_addr) { "non_existent_wallet_address" }
      let(:step_name) { "onboard_screens" }

      it "creates a new tutorial progress with the step" do
        result = described_class.call(wallet_addr, step_name)
        expect(result).to be_a(TutorialProgress)
        expect(result.steps.last.name).to eq(step_name)
        expect(result.completed).to be_falsey
      end
    end
  end
end
