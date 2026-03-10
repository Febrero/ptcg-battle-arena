module Kafka
  class TicketLockerAndDistributionEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.battle_arena.ticket_locker_and_distribution"
    self.group_id = "arena_ticket_locker_and_distribution"

    def process(message)
      Rails.logger.info "Going to process a distribution event"

      parsed_message = JSON.parse(message.value)

      TicketLockerAndDistributionEventJob.perform_async(parsed_message)
    end
  end
end
