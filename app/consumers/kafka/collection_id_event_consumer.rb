module Kafka
  class CollectionIdEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.marketplace.collection_id"
    self.group_id = "arena_collection_id"

    def process(message)
      Rails.logger.info "Going to process a collection id event"

      parsed_message = JSON.parse(message.value)

      CollectionIdEventJob.perform_async(parsed_message)
    end
  end
end
