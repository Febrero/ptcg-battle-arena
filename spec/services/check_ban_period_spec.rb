require "rails_helper"

RSpec.describe CheckBanPeriod do
  before {
    get_redis.del get_redis.keys("*UserBanInfo*")
  }
  describe ".call" do
    it "should return the info saved on the redis key" do
      wallet_addr = "0x123qwe"
      get_redis.set(UserBanPeriod.redis_key(wallet_addr), "123")

      expect(subject.call(wallet_addr)).to eq("123")
    end

    it "should return a default value if the redis key doesn't exist" do
      expect(subject.call("0xWallet_not_found")).to eq({banned: false})
    end
  end
end
