module Kafka
  class OpenerEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.marketplace.opener"
    self.group_id = "arena_opener"

    def process(message)
      Rails.logger.info "Going to process a opener event"

      parsed_message = JSON.parse(message.value)

      OpenerEventJob.perform_async(parsed_message)
    end
  end
end
