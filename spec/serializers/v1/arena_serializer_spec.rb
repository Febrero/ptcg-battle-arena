require "rails_helper"

RSpec.describe V1::ArenaSerializer, type: :serializer, vcr: true do
  subject { V1::ArenaSerializer.new(arena).serializable_hash }

  let!(:arena) { create(:arena) }
  let!(:reward_config_win) { create(:reward_config) }
  let!(:reward_config_play) { create(:reward_config, :play) }

  describe "attributes" do
    it {
      expect(subject).to include(:uid, :name, :total_prize_pool, :prize_pool_winner_share,
        :prize_pool_realfevr_share, :compatible_ticket_ids, :active, :card_image_url, :background_image_url, :erc20, :xp_info)
    }

    it "xp_info attribute should return all reward configs" do
      parsed_xp_info = JSON.parse(subject[:xp_info].to_json)

      expect(parsed_xp_info.length).to eq(2)
    end

    it "xp_info attribute should return the fields of each reward config" do
      parsed_xp_info = JSON.parse(subject[:xp_info].to_json)
      win_data = {"achievement_type" => reward_config_win.achievement_type,
                  "achievement_value" => reward_config_win.achievement_value,
                  "desc" => reward_config_win.desc}

      expect(parsed_xp_info.include?(win_data)).to be_truthy
    end
  end
end
