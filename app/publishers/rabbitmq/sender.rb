require "bunny"
#
# call it like Rabbitmq::Sender.publish_to_queue("queue_name",{test: "asd"})
#
module Rabbitmq
  class Sender
    attr_reader :connection

    def initialize
      @connection = Bunny.new(Rails.application.config.rabbitmq)
      @connection.start
    end

    def publish_to_queue(queue_name, msg)
      with_channel_and_queue(queue_name) do |channel, queue|
        channel.default_exchange.publish(msg.to_json, routing_key: queue.name)
      end
    end

    def publish_to_topic(exchange_name, topic, message)
      with_channel_and_topic(exchange_name) do |channel, exchange|
        exchange.publish(message, routing_key: topic)
      end
    end

    def publish_to_exchange(direct_exchange, routing_key, msg)
      with_channel_and_exchange(direct_exchange) do |channel, exchange|
        exchange.publish(msg.to_json, routing_key: routing_key)
      end
    end

    def self.method_missing(method_name, *args)
      new.send(method_name, *args)
    end

    def self.respond_to_missing?(method_name, include_private = false)
      public_methods(false).include?(method_name.to_sym)
    end

    private

    def with_channel_and_queue(queue_name)
      channel = connection.create_channel
      queue = channel.queue(queue_name)
      yield channel, queue
      connection.close
    end

    def with_channel_and_exchange(direct_exchange)
      channel = connection.create_channel
      exchange = channel.direct(direct_exchange)
      yield channel, exchange
      connection.close
    end

    def with_channel_and_topic(exchange_name)
      channel = connection.create_channel
      exchange = channel.topic(exchange_name)
      yield channel, exchange
      connection.close
    end
  end
end
