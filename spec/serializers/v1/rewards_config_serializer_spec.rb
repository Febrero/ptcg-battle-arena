require "rails_helper"

RSpec.describe V1::RewardsConfigSerializer, type: :serializer do
  let(:reward_config) { create(:reward_config) }

  subject { V1::RewardsConfigSerializer.new(reward_config).serializable_hash }

  describe "attributes" do
    it { expect(subject).to include(:achievement_type, :achievement_value, :desc) }
  end
end
