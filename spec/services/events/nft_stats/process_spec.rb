require "rails_helper"
RSpec.describe Events::NftsStats::Process do
  describe "#call" do
    let(:nft_stats) {
      {
        "Uuid" => -1,
        "VideoId" => 172,
        "PlayerPosition" => "Fw",
        "GoalLineStats" => {
          "DamageDealtAttacking" => 0,
          "DamageDealtDefending" => 0,
          "OverkillDamageDealtAttacking" => 0,
          "OverkillDamageDealtDefending" => 0,
          "DamageReceivedAttacking" => 0,
          "DamageReceivedDefending" => 0,
          "OverkillDamageReceivedAttacking" => 0,
          "OverkillDamageReceivedDefending" => 0,
          "GoalsScored" => 0,
          "MomentsDestroyedAttacking" => 0,
          "MomentsDestroyedDefending" => 0,
          "AttacksMade" => 0,
          "AttacksReceived" => 0,
          "StaminaGrantedWithBuffs" => 0,
          "ActivePowerGrantedWithBuffs" => 0,
          "SuperSubUsedAfterPlaced" => 0,
          "EndOfTurnReached" => 8
        },
        "DefenseLineStats" => {
          "DamageDealtAttacking" => 8,
          "DamageDealtDefending" => 1,
          "OverkillDamageDealtAttacking" => 3,
          "OverkillDamageDealtDefending" => 0,
          "DamageReceivedAttacking" => 12,
          "DamageReceivedDefending" => 3,
          "OverkillDamageReceivedAttacking" => 8,
          "OverkillDamageReceivedDefending" => 0,
          "GoalsScored" => 0,
          "MomentsDestroyedAttacking" => 3,
          "MomentsDestroyedDefending" => 0,
          "AttacksMade" => 3,
          "AttacksReceived" => 1,
          "StaminaGrantedWithBuffs" => 1,
          "ActivePowerGrantedWithBuffs" => 0,
          "SuperSubUsedAfterPlaced" => 0,
          "EndOfTurnReached" => 24
        },
        "AttackLineStats" => {
          "DamageDealtAttacking" => 18,
          "DamageDealtDefending" => 14,
          "OverkillDamageDealtAttacking" => 5,
          "OverkillDamageDealtDefending" => 5,
          "DamageReceivedAttacking" => 36,
          "DamageReceivedDefending" => 15,
          "OverkillDamageReceivedAttacking" => 17,
          "OverkillDamageReceivedDefending" => 5,
          "GoalsScored" => 2,
          "MomentsDestroyedAttacking" => 6,
          "MomentsDestroyedDefending" => 4,
          "AttacksMade" => 9,
          "AttacksReceived" => 5,
          "StaminaGrantedWithBuffs" => 0,
          "ActivePowerGrantedWithBuffs" => 2,
          "SuperSubUsedAfterPlaced" => 0,
          "EndOfTurnReached" => 17
        },
        "AbilitiesStats" => {
          "SuperSub" => 0,
          "Captain" => 1,
          "Inspire" => 2,
          "BallStopper" => 4,
          "LongPasser" => 0,
          "BoxToBox" => 0,
          "Dribbler" => 1,
          "Manmark" => 0
        }
      }
    }

    let(:event) {
      {
        "WalletAddr" => "0x123",
        "GameId" => "123-123",
        "NFTStats" => [nft_stats]
      }
    }

    before do
      allow(TopMoments::GoalLineStats).to receive(:create!)
      allow(TopMoments::DefenseLineStats).to receive(:create!)
      allow(TopMoments::AttackLineStats).to receive(:create!)
      allow(TopMoments::AbilitiesStats).to receive(:create!)
      allow(NftsStatsInvalidateTopMomentsJob).to receive(:perform_async)
    end

    it "creates line stats for each NFTStats" do
      expect(TopMoments::GoalLineStats).to receive(:create!).with(line_stats(event, "GoalLineStats"))
      expect(TopMoments::DefenseLineStats).to receive(:create!).with(line_stats(event, "DefenseLineStats"))
      expect(TopMoments::AttackLineStats).to receive(:create!).with(line_stats(event, "AttackLineStats"))
      expect(TopMoments::AbilitiesStats).to receive(:create!).with(line_stats(event, "AbilitiesStats"))

      Events::NftsStats::Process.call(event)
    end

    it "performs NftsStatsInvalidateTopMomentsJob asynchronously" do
      expect(NftsStatsInvalidateTopMomentsJob).to receive(:perform_async).with(event["WalletAddr"])

      Events::NftsStats::Process.call(event)
    end
  end

  def line_stats(event, lane)
    stats = event["NFTStats"][0]
    nft_stats = {
      nft_uid: stats["Uuid"],
      video_id: stats["VideoId"],
      position: stats["PlayerPosition"],
      wallet_addr: event["WalletAddr"],
      game_id: event["GameId"]
    }

    stats[lane].each do |stat_name, stat_value|
      nft_stats[stat_name.underscore.to_sym] = stat_value
    end

    nft_stats
  end
end
