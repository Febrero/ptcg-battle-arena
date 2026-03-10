module Kafka
  class TicketFactoryEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.battle_arena.ticket_factory"
    self.group_id = "arena_factory"

    def process(message)
      Rails.logger.info "Going to process a ticket factory event"

      parsed_message = JSON.parse(message.value)

      TicketFactoryEventJob.perform_async(parsed_message)
    end
  end
end
