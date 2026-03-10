module StartGameLock
  class Unlock < ApplicationService
    def call(address)
      redis.del("StartGameLock::#{address}")
    end

    private

    def redis
      @_redis ||= get_redis
    end
  end
end
