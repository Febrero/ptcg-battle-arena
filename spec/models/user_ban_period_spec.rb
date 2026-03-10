require "rails_helper"

RSpec.describe UserBanPeriod, type: :model do
  it { should validate_presence_of(:wallet_addr) }
  it { should validate_uniqueness_of(:wallet_addr) }

  describe "indexes" do
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "user_ban_wallet_addr_index", unique: true) }
    it { is_expected.to have_index_for(created_at: 1).with_options(name: "user_ban_expire_index", expire_after_seconds: 604800) }
  end

  describe "callbacks" do
    it "should downcase the wallet when creating the record" do
      user_ban = create(:user_ban_period, wallet_addr: "0xABC", wallet_addr_downcased: nil)

      expect(user_ban.wallet_addr_downcased).to eq("0xABC".downcase)
    end

    it "should downcase the wallet when creating the record" do
      user_ban = create(:user_ban_period, counter_updated_at: nil)

      expect(user_ban.counter_updated_at).not_to be_nil
    end

    it "should downcase the wallet when updating the record" do
      user_ban = create(:user_ban_period)

      initial_counter_updated_at = user_ban.counter_updated_at

      user_ban.update(counter: 2)

      expect(user_ban.counter_updated_at).not_to eq(initial_counter_updated_at)
    end
  end

  it "should return a redis key composed with a given wallet_addr" do
    wallet_addr = "0x123"

    expect(UserBanPeriod.redis_key(wallet_addr)).to eq(UserBanPeriod::REDIS_KEY_PATTERN + wallet_addr)
  end

  describe "calculate ban timeframe" do
    it "should return the timeframe basec on the counter" do
      user_ban = create(:user_ban_period, counter: 2)

      expect(user_ban.ban_timeframe).to eq(UserBanPeriod::BAN_TIMEFRAMES["2"])
    end

    it "should return a default timeframe if no config for this counter is found" do
      user_ban = create(:user_ban_period, counter: 1000)

      expect(user_ban.ban_timeframe).to eq(UserBanPeriod::BAN_TIMEFRAMES["default"])
    end
  end

  it "should calculate the date until the ban is valid" do
    time = Time.now

    user_ban = create(:user_ban_period, counter: 2, counter_updated_at: time)

    expect(user_ban.banned_until.to_i).to eq((time + UserBanPeriod::BAN_TIMEFRAMES["2"]).to_i)
  end
end
