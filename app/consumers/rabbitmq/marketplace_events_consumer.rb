require "bunny"

module Rabbitmq
  class MarketplaceEventsConsumer
    attr_accessor :connection, :channel, :exchange, :queue

    def initialize
      Rails.logger.info "Initializing the marketplace events consumer"
      $stdout.flush

      @connection = Bunny.new(Rails.application.config.rabbitmq)

      connection.start

      @channel = connection.create_channel
      @exchange = channel.topic("marketplace_events")
      @queue = channel.queue("battle_arena.marketplace_events", durable: true, auto_delete: false)

      @queue.bind(exchange, routing_key: "video.*")
    end

    def run
      Rails.logger.info "\t Running the marketplace events consumer"
      $stdout.flush
      queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
        msg_details = JSON.parse(body)

        Rails.logger.info "delivery_info: #{delivery_info}"
        Rails.logger.info "properties: #{properties}"
        Rails.logger.info "body: #{msg_details}"
        $stdout.flush

        HandleMarketplaceEvent.call(delivery_info[:routing_key], msg_details)

        channel.ack(delivery_info.delivery_tag)
      end
    rescue Interrupt => _e
      channel.close
      connection.close
    end
  end
end
