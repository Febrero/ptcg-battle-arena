module Tickets
  class BaseSpendTickets
    include Callable

    private

    def entry_already_charged?
      redis.get(redis_key) == "charged"
    end

    def del_entry_key
      redis.del(redis_key)
    end

    def set_entry_key
      redis.set(redis_key, "charged")
    end

    def redis
      @_redis ||= get_redis
    end

    def redis_key
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def charge_entry
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
