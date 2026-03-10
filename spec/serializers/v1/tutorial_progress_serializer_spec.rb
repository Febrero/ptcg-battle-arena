# spec/serializers/tutorial_progress_serializer_spec.rb

require "rails_helper"

RSpec.describe V1::TutorialProgressSerializer, type: :serializer do
  describe "serialization" do
    let(:wallet_addr) { "example_wallet_address" }
    let(:downcased_wallet_addr) { wallet_addr.downcase }
    let!(:tutorial_progress) do
      create(:tutorial_progress, wallet_addr: wallet_addr, wallet_addr_downcased: downcased_wallet_addr) do |tutorial_progress|
        tutorial_progress.steps << build(:step, name: TutorialProgress::STEPS.first)
      end
    end

    context "when serializing a TutorialProgress instance" do
      let(:serializer) { described_class.new(tutorial_progress) }
      let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
      let(:serialized_data) { JSON.parse(serialization.to_json) }

      it "includes the expected attributes" do
        expect(serialized_data.keys).to match_array(["wallet_addr", "wallet_addr_downcased", "completed", "completion_date", "steps"])
      end

      it "serializes wallet_addr attribute" do
        expect(serialized_data["wallet_addr"]).to eq(wallet_addr)
      end

      it "serializes wallet_addr_downcased attribute" do
        expect(serialized_data["wallet_addr_downcased"]).to eq(downcased_wallet_addr)
      end

      it "serializes completed attribute" do
        expect(serialized_data["completed"]).to eq(tutorial_progress.completed)
      end

      it "serializes completion_date attribute" do
        expect(serialized_data["completion_date"]).to eq(tutorial_progress.completion_date)
      end

      it "serializes steps attribute as an array of step objects" do
        expect(serialized_data["steps"]).to be_an(Array)
        expect(serialized_data["steps"].first.keys).to match_array(["name", "created_at"])
      end
    end
  end
end
