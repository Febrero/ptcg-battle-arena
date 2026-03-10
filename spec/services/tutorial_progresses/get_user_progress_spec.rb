# spec/services/tutorial_progresses/get_user_progress_spec.rb

require "rails_helper"

module TutorialProgresses
  RSpec.describe GetUserProgress, type: :service do
    describe "#call" do
      let(:service) { GetUserProgress.new }

      context "when the user's tutorial progress exists" do
        let(:wallet_addr) { "example_wallet_address" }
        let(:downcased_wallet_addr) { wallet_addr.downcase }
        let!(:tutorial_progress) do
          create(:tutorial_progress, wallet_addr: wallet_addr, wallet_addr_downcased: downcased_wallet_addr) do |tutorial_progress|
            tutorial_progress.steps << build(:step, name: TutorialProgress::STEPS.first)
          end
        end

        context "when the tutorial is completed" do
          before do
            tutorial_progress.update(completed: true)
          end

          it "returns 'done'" do
            result = service.call(wallet_addr)
            expect(result).to eq("done")
          end
        end

        context "when the tutorial is not completed" do
          let(:step_name) { "tutorial_training" }

          before do
            tutorial_progress.steps.create(name: step_name)
          end

          it "returns the name of the last completed step" do
            result = service.call(wallet_addr)
            expect(result).to eq(step_name)
          end
        end
      end

      context "when the user's tutorial progress does not exist" do
        let(:wallet_addr) { "non_existent_wallet_address" }

        it "returns nil" do
          result = service.call(wallet_addr)
          expect(result).to be_nil
        end
      end
    end
  end
end
