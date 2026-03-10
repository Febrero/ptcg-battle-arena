class UserBanPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  REDIS_KEY_PATTERN = "UserBanInfo::"

  BAN_TIMEFRAMES = {
    "1" => 0,
    "2" => 10.minutes,
    "3" => 1.hour,
    "4" => 4.hours,
    "5" => 12.hours,
    "default" => 1.day
  }

  field :wallet_addr, type: String
  field :wallet_addr_downcased, type: String
  field :counter, type: Integer, default: 0
  field :counter_updated_at, type: DateTime, default: -> { Time.now }
  field :game_id, type: String

  index({wallet_addr: 1}, {name: "user_ban_wallet_addr_index", unique: true})
  index({created_at: 1}, {name: "user_ban_expire_index", expire_after_seconds: 604800}) # expires after 1 week

  validates :wallet_addr, presence: true, uniqueness: true

  def self.redis_key wallet_addr
    REDIS_KEY_PATTERN + wallet_addr
  end

  def ban_timeframe
    BAN_TIMEFRAMES.has_key?(counter.to_s) ? BAN_TIMEFRAMES[counter.to_s] : BAN_TIMEFRAMES["default"]
  end

  def banned_until
    counter_updated_at + ban_timeframe
  end
end
