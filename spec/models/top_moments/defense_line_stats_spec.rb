require "rails_helper"
RSpec.describe TopMoments::DefenseLineStats, type: :model do
  describe "fields" do
    it { is_expected.to have_field(:lane).of_type(Integer).with_default_value_of(TopMoments::NftStats::LANE_DEFENSE_LINE) }
  end

  describe "inheritance" do
    it "inherits from NftStats" do
      expect(described_class.superclass).to eq(TopMoments::NftStats)
    end
  end
end
