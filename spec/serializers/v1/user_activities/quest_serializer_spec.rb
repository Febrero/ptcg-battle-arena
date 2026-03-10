require "rails_helper"

RSpec.describe V1::UserActivities::QuestSerializer, type: :serializer do
  let!(:quest_profile) { create(:quest_profile) }
  let!(:activity) do
    create(
      :user_activity,
      wallet_addr: "0x123",
      event_info: {day: quest_profile.count},
      source: quest_profile.quest
    )
  end

  subject { V1::UserActivities::QuestSerializer.new(activity).serializable_hash }

  it "contains info related to quest activity" do
    expect(subject).to include(:day)
  end
end
