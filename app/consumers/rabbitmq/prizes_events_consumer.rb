require "bunny"

module Rabbitmq
  class PrizesEventsConsumer
    attr_accessor :connection, :channel, :exchange, :queue

    def initialize
      Rails.logger.info "Initializing the prizes events consumer"
      $stdout.flush

      @connection = Bunny.new(Rails.application.config.rabbitmq)

      connection.start

      @channel = connection.create_channel
      @exchange = channel.topic("prizes_events")
      @queue = channel.queue("battle_arena.prizes_events", durable: true, auto_delete: false)

      @queue.bind(exchange, routing_key: "prize.*")
    end

    def run
      Rails.logger.info "\t Running the prizes events consumer"
      $stdout.flush
      queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
        msg_details = JSON.parse(body)

        Rails.logger.info "delivery_info: #{delivery_info}"
        Rails.logger.info "properties: #{properties}"
        Rails.logger.info "body: #{msg_details}"
        $stdout.flush

        UserActivities::HandleRewardEvent.call(msg_details, "prizes")

        channel.ack(delivery_info.delivery_tag)
      end
    rescue Interrupt => _e
      channel.close
      connection.close
    end
  end
end
