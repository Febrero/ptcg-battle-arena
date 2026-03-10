module Rabbitmq
  class PlayoffsPublisher
    def self.send(topic, msg)
      Rabbitmq::Sender.publish_to_topic("battle_arena.playoffs", topic, msg)
    end
  end
end
