module StartGameLock
  class Lock < ApplicationService
    def call(address)
      redis.set("StartGameLock::#{address}", 1.minute.from_now)
    end

    private

    def redis
      @_redis ||= get_redis
    end
  end
end
