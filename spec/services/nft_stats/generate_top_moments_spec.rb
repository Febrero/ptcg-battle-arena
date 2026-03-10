require "rails_helper"

RSpec.describe NftStats::GenerateTopMoments do
  describe "#call" do
    let(:wallet_addr) { "0x123" }
    let(:base_event) { {wallet_addr: wallet_addr, wallet_addr_downcase: wallet_addr, video_id: 1, moments_destroyed_attacking: 2, moments_destroyed_defending: 1, end_of_turn_reached: 1, nft_uid: -1} }

    let(:goal_line_stats) {
      create(:goal_line_stats, base_event.merge({attacks_received: 1, moments_destroyed_attacking: 2}))
      create(:goal_line_stats, base_event.merge({attacks_received: 1, moments_destroyed_attacking: 3}))
      create(:goal_line_stats, base_event.merge({attacks_received: 1, video_id: 3, moments_destroyed_attacking: 3}))
      create(:goal_line_stats, base_event.merge({attacks_received: 1, video_id: 4, moments_destroyed_attacking: 1}))
      create(:goal_line_stats, base_event.merge({attacks_received: 1, video_id: 5, moments_destroyed_attacking: 1}))
    }
    let(:goal_line_stats_not_zero) {
      create(:goal_line_stats, base_event.merge({attacks_received: 1, moments_destroyed_attacking: 2}))
      create(:goal_line_stats, base_event.merge({video_id: 2, attacks_received: 0, moments_destroyed_attacking: 0, moments_destroyed_defending: 0, end_of_turn_reached: 0}))
    }

    let(:defense_line_stats) {
      create(:defense_line_stats, base_event.merge({attacks_received: 1, damage_received_defending: 2}))
      create(:defense_line_stats, base_event.merge({attacks_received: 1, damage_received_defending: 3}))
      create(:defense_line_stats, base_event.merge({attacks_received: 1, video_id: 3, damage_received_defending: 3}))
    }

    let(:attack_line_stats) {
      create(:attack_line_stats, base_event.merge({goals_scored: 1, damage_dealt_attacking: 2, overkill_damage_dealt_attacking: 5}))
      create(:attack_line_stats, base_event.merge({goals_scored: 1, damage_dealt_attacking: 2, overkill_damage_dealt_attacking: 5}))
      create(:attack_line_stats, base_event.merge({goals_scored: 1, video_id: 3, damage_dealt_attacking: 2, overkill_damage_dealt_attacking: 5}))
    }

    let(:nft_stats) { double("NftStats") }

    before do
      allow(TopMoments::NftStats).to receive(:ownership_last_updated_at).with(wallet_addr).and_return(Time.now)
      allow(Rails.cache).to receive(:fetch).and_yield
    end

    it "fetches top moments statistics from cache" do
      allow(Rails.cache).to receive(:fetch).and_return(nil) # its not necesssary check yield
      expect(Rails.cache).to receive(:fetch).with("TopMoments::NftsStats::#{wallet_addr}::#{Time.now}", expires_in: 1.day)
      NftStats::GenerateTopMoments.call(wallet_addr)
    end

    it "calculates top moments goal line" do
      allow(Rails.cache).to receive(:fetch).and_yield
      goal_line_stats
      top_moments_result = NftStats::GenerateTopMoments.call(wallet_addr)
      expect(top_moments_result["goal_line_stats"]).to eq([
        {
          goals_avoided: 2,
          opponents_destroyed: 7,
          turns_played: 2,
          video_id: 1,
          rarity: "grey"
        },
        {
          goals_avoided: 1,
          opponents_destroyed: 4,
          turns_played: 1,
          video_id: 3,
          rarity: "grey"
        },
        {
          goals_avoided: 1,
          opponents_destroyed: 2,
          turns_played: 1,
          video_id: 4,
          rarity: "grey"
        }
      ])
    end

    it "calculates top moments defense line" do
      allow(Rails.cache).to receive(:fetch).and_yield
      defense_line_stats
      top_moments_result = NftStats::GenerateTopMoments.call(wallet_addr)
      expect(top_moments_result["defense_line_stats"]).to eq([
        {
          damage_absorved: 5,
          opponents_destroyed: 6,
          turns_played: 2,
          video_id: 1,
          rarity: "grey"
        },
        {
          damage_absorved: 3,
          opponents_destroyed: 3,
          turns_played: 1,
          video_id: 3,
          rarity: "grey"
        }
      ])
    end

    it "calculates top moments attack line" do
      allow(Rails.cache).to receive(:fetch).and_yield
      attack_line_stats
      top_moments_result = NftStats::GenerateTopMoments.call(wallet_addr)
      expect(top_moments_result["attack_line_stats"]).to eq([
        {
          goals_scored: 2,
          damage_dealt: -6,
          opponents_destroyed: 6,
          video_id: 1,
          rarity: "grey"
        },
        {
          goals_scored: 1,
          damage_dealt: -3,
          opponents_destroyed: 3,
          video_id: 3,
          rarity: "grey"
        }
      ])
    end

    it "sorts and limits the top moments by sorting field" do
      goal_line_stats
      top_moments_result = NftStats::GenerateTopMoments.call(wallet_addr)
      expect(top_moments_result["goal_line_stats"].count).to eq(3)
      expect(top_moments_result["goal_line_stats"].first[:video_id]).to eq(1)
    end

    it "not count stat filled with zero" do
      goal_line_stats_not_zero
      top_moments_result = NftStats::GenerateTopMoments.call(wallet_addr)
      expect(top_moments_result["goal_line_stats"].count).to eq(1)
      expect(top_moments_result["goal_line_stats"].first[:video_id]).to eq(1)
    end
  end
end
