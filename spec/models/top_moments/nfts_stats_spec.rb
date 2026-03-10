require "rails_helper"
RSpec.describe TopMoments::NftStats, type: :model do
  describe "fields" do
    it { is_expected.to have_field(:uid).of_type(String) }
    it { is_expected.to have_field(:nft_uid).of_type(Integer) }
    it { is_expected.to have_field(:video_id).of_type(Integer) }
    it { is_expected.to have_field(:position).of_type(String) }
    it { is_expected.to have_field(:wallet_addr).of_type(String) }
    it { is_expected.to have_field(:wallet_addr_downcase).of_type(String) }
    it { is_expected.to have_field(:game_id).of_type(String) }
    it { is_expected.to have_field(:damage_dealt_attacking).of_type(Integer) }
    it { is_expected.to have_field(:damage_dealt_defending).of_type(Integer) }
    it { is_expected.to have_field(:overkill_damage_dealt_attacking).of_type(Integer) }
    it { is_expected.to have_field(:overkill_damage_dealt_defending).of_type(Integer) }
    it { is_expected.to have_field(:goals_scored).of_type(Integer) }
    it { is_expected.to have_field(:moments_destroyed_attacking).of_type(Integer) }
    it { is_expected.to have_field(:moments_destroyed_defending).of_type(Integer) }
    it { is_expected.to have_field(:attacks_made).of_type(Integer) }
    it { is_expected.to have_field(:attacks_received).of_type(Integer) }
    it { is_expected.to have_field(:stamina_granted_with_buffs).of_type(Integer) }
    it { is_expected.to have_field(:active_power_granted_with_buffs).of_type(Integer) }
    it { is_expected.to have_field(:super_sub_used_after_placed).of_type(Integer) }
    it { is_expected.to have_field(:end_of_turn_reached).of_type(Integer) }
    it { is_expected.to have_field(:damage_received_attacking).of_type(Integer) }
    it { is_expected.to have_field(:damage_received_defending).of_type(Integer) }
    it { is_expected.to have_field(:overkill_damage_received_attacking).of_type(Integer) }
    it { is_expected.to have_field(:overkill_damage_received_defending).of_type(Integer) }
    it { is_expected.to have_timestamps }
  end

  describe "indexes" do
    it { is_expected.to have_index_for(uid: 1).with_options(unique: true, name: "uid_index", background: true) }
    it { is_expected.to have_index_for(game_id: 1).with_options(name: "game_id_index", background: true) }
    it { is_expected.to have_index_for(nft_uid: 1).with_options(name: "nft_uid_index", background: true) }
    it { is_expected.to have_index_for(video_id: 1).with_options(name: "video_id_index", background: true) }
    it { is_expected.to have_index_for(position: 1).with_options(name: "position_index", background: true) }
    it { is_expected.to have_index_for(wallet_addr_downcase: 1).with_options(name: "wallet_addr_downcase_index", background: true) }
    it { is_expected.to have_index_for(lane: 1).with_options(name: "lane_index", background: true) }
  end

  describe "enums" do
    it {
      expect(TopMoments::NftStats::LANE_GOAL_LINE).to eq(0)
      expect(TopMoments::NftStats::LANE_DEFENSE_LINE).to eq(1)
      expect(TopMoments::NftStats::LANE_ATTACK_LINE).to eq(2)
      expect(TopMoments::NftStats::LANE_ABILITIES).to eq(3)
    }
  end

  describe "#generate_uid" do
    let(:nft_stats) { build(:defense_line_stats) }

    it "generates the UID based on the attributes" do
      expected_uid = "#{nft_stats.game_id}|#{nft_stats.wallet_addr_downcase}|#{nft_stats.video_id}|#{nft_stats.nft_uid}|#{nft_stats.lane}|v1"
      expect(nft_stats.generate_uid).to eq(expected_uid)
    end
  end
end
