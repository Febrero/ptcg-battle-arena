require "rails_helper"

RSpec.describe PlayerProfile::Stats::Moments, vcr: true do
  describe ".call" do
    it "returns the stats of games" do
      result = described_class.call("0xlolarilole")

      expect(result.keys).to match_array(["common", "special", "epic", "legendary", "unique", "total"])
    end
  end
end
