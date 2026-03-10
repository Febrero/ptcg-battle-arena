module StartGameLock
  class Locked < ApplicationService
    def call(address)
      redis.get("StartGameLock::#{address}")
    end

    private

    def redis
      @_redis ||= get_redis
    end
  end
end
