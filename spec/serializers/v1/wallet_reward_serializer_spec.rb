require "rails_helper"

RSpec.describe V1::WalletRewardSerializer, type: :serializer do
  let(:reward_xp1) {
    Rewards::Reward.new(wallet_addr: "0x12345", id: 12345, value: 10, final_value: 10000, state: "delivered", reward_type: "xp", event_detail: {xp_detailed: {hello: {amount: 1, xp_points: 10}}})
  }
  let(:reward_xp2) {
    Rewards::Reward.new(wallet_addr: "0x12345", id: 12345, value: 10, final_value: nil, state: "delivered", reward_type: "xp")
  }
  let(:reward_whitelist) {
    Rewards::Reward.new(wallet_addr: "0x12345", id: 12345, value: 1, final_value: nil, state: "delivered", reward_type: "white_list", event_detail: {xp_detailed: {foo: "bar"}})
  }

  subject { V1::WalletRewardSerializer.new(reward_xp1).serializable_hash }

  describe "attributes" do
    it { expect(subject).to include(:wallet_addr, :total_value, :reward_type, :xp_detail) }

    it "total_value attribute should return the final_value if it exists" do
      expect(subject[:total_value]).to eq(10000)
    end

    it "total_value attribute should return the value if the final_value doesn't exist" do
      serialized_obj = V1::WalletRewardSerializer.new(reward_xp2).serializable_hash

      expect(serialized_obj[:total_value]).to eq(10)
    end

    it "xp_detail attribute should return the info on event_detail for xp only rewards" do
      serialized_obj = V1::WalletRewardSerializer.new(reward_xp1).serializable_hash

      expect(serialized_obj[:xp_detail]).to match_array([{name: "Hello", amount: 1, xp_points: 10}])
    end

    it "xp_detail attribute should return an empty hash for a reward other than a xp one" do
      serialized_obj = V1::WalletRewardSerializer.new(reward_whitelist).serializable_hash

      expect(serialized_obj[:xp_detail]).to eq([])
    end
  end
end
