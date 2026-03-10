module Rabbitmq
  class PrizesPublisher
    def self.send(msg)
      Rabbitmq::Sender.publish_to_exchange("battle_arena_games", "prizes", msg)
    end
  end
end
