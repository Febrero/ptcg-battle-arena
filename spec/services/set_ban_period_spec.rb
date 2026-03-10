require "rails_helper"

RSpec.describe SetBanPeriod do
  before {
    get_redis.del get_redis.keys("*UserBanInfo*")
  }
  describe ".call" do
    it "should create a new record for that wallet if none exists" do
      expect {
        subject.call("0x123qwe", "game_id_cenas")
      }.to change {
        UserBanPeriod.count
      }.by(1)
    end

    it "should update the counter for an existing record for that wallet" do
      subject.call("0x123qwe", "game_id_cenas")

      expect {
        subject.call("0x123qwe", "game_id_cenas")
      }.to change {
        UserBanPeriod.find_by(wallet_addr: "0x123qwe").counter
      }.by(1)
    end

    it "should not set info with the current ban on redis if the timeframe is 0" do
      expect {
        subject.call("0x123qweRTY", "game_id_cenas")
      }.not_to change {
        get_redis.get(UserBanPeriod.redis_key("0x123qweRTY"))
      }
    end

    it "should set info with the current ban on redis" do
      create(:user_ban_period, wallet_addr: "0x123qweRTY", counter: 1000)

      expect {
        subject.call("0x123qweRTY", "game_id_cenas")
      }.to change {
        get_redis.get(UserBanPeriod.redis_key("0x123qweRTY"))
      }.from(nil).to(Object)
    end
  end
end
