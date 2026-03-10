require "rails_helper"

RSpec.describe AssistedGamer, type: :model, x: :x do
  subject { described_class.new }

  describe "indexes" do
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "wallet_addr_index", background: true, unique: true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:wallet_addr) }
    it { is_expected.to validate_presence_of(:week_days_that_play) }
    it { is_expected.to validate_presence_of(:day_hours_that_play) }
    it { is_expected.to validate_presence_of(:ai_mode) }
  end

  it "should have 3 ai modes" do
    expect(AssistedGamer::AI_MODES).to match_array(["Ari", "Bex", "Clyde"])
  end
end
