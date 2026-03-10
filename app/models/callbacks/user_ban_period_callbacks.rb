module Callbacks
  module UserBanPeriodCallbacks
    def before_create(user_ban_period)
      user_ban_period.wallet_addr_downcased = user_ban_period.wallet_addr.downcase
    end

    def before_save(user_ban_period)
      user_ban_period.counter_updated_at = Time.now
    end
  end
end
