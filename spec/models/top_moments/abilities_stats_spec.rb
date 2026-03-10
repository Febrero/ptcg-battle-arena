require "rails_helper"
RSpec.describe TopMoments::AbilitiesStats, type: :model do
  describe "fields" do
    it { is_expected.to have_field(:super_sub).of_type(Integer) }
    it { is_expected.to have_field(:captain).of_type(Integer) }
    it { is_expected.to have_field(:inspire).of_type(Integer) }
    it { is_expected.to have_field(:ball_stopper).of_type(Integer) }
    it { is_expected.to have_field(:long_passer).of_type(Integer) }

    it { is_expected.to have_field(:box_to_box).of_type(Integer) }
    it { is_expected.to have_field(:dribbler).of_type(Integer) }
    it { is_expected.to have_field(:manmark).of_type(Integer) }

    it { is_expected.to have_field(:lane).of_type(Integer).with_default_value_of(TopMoments::NftStats::LANE_ABILITIES) }
  end

  describe "inheritance" do
    it "inherits from NftStats" do
      expect(described_class.superclass).to eq(TopMoments::NftStats)
    end
  end
end
