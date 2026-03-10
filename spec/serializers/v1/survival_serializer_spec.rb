require "rails_helper"

RSpec.describe V1::SurvivalSerializer, type: :serializer, vcr: true do
  let(:survival) { create(:survival) }

  subject { V1::SurvivalSerializer.new(survival).serializable_hash }

  describe "attributes" do
    it {
      expect(subject).to include(:uid, :name, :total_prize_pool, :prize_pool_winner_share,
        :prize_pool_realfevr_share, :compatible_ticket_ids, :active,
        :background_image_url, :erc20,
        :erc20_name, :start_date, :end_date, :state, :min_deck_tier,
        :max_deck_tier, :acceptance_rules, :levels_count, :game_mode)
    }

    it "should return an array of stages" do
      expect(subject[:survival_stages]).to be_a(Array)
    end

    it "should return stages without the _id" do
      expect(subject[:survival_stages].none? { |e| e.has_key?("_id") }).to be_truthy
    end

    it "should return a survival game_mode" do
      expect(subject[:game_mode]).to eq("Survival")
    end
  end
end
