require "bunny"

module Rabbitmq
  class GameEventConsumer
    attr_accessor :connection, :channel, :exchange, :queue

    def initialize
      Rails.logger.info "Initializing the game_event consumer"
      $stdout.flush

      @connection = Bunny.new(Rails.application.config.rabbitmq)

      connection.start

      @channel = connection.create_channel
      @exchange = channel.direct("battle_arena_games")
      @queue = channel.queue("leaderboards.game_event", durable: true, auto_delete: false)

      @queue.bind(exchange, routing_key: "game_event")
    end

    def run
      Rails.logger.info "\t Running the game_event consumer"
      queue.subscribe(block: true, manual_ack: true) do |delivery_info, _properties, body|
        game_details = JSON.parse(body)

        Rails.logger.info "body: #{game_details}"
        $stdout.flush
        ProcessGameEvent.call(game_details)

        channel.ack(delivery_info.delivery_tag)
      end
    rescue Interrupt => _e
      channel.close
      connection.close
    end
  end
end
