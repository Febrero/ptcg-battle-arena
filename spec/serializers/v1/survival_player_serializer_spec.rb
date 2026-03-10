require "rails_helper"

RSpec.describe V1::SurvivalPlayerSerializer, type: :serializer do
  let(:survival_player) { create(:survival_player) }

  subject { V1::SurvivalPlayerSerializer.new(survival_player).serializable_hash }

  describe "attributes" do
    it { expect(subject).to include(:wallet_addr, :current_active_entry, :player_entries, :survival_id) }

    it "should return an array of entries" do
      expect(subject[:player_entries]).to be_a(Array)
    end

    it "should return entries without the _id" do
      expect(subject[:player_entries].none? { |e| e.has_key?("_id") }).to be_truthy
    end

    it "should return active-entry without the _id" do
      expect(subject[:current_active_entry].has_key?("_id")).to be_falsy
    end
  end
end
