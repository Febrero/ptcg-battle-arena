require "rails_helper"

RSpec.describe V1::QuestStreakSerializer, type: :serializer do
  let(:quest_profile) { create(:quest_profile) }
  let(:quest_streak) { create(:quest_streak, profile: quest_profile) }

  subject { V1::QuestStreakSerializer.new(quest_streak).serializable_hash }

  describe "attributes" do
    it "inclues the correct fields" do
      expect(subject).to include(:id, :count, :profile_id, :claims, :end_date, :wallet_addr)
    end
  end
end
