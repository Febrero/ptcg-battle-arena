module Kafka
  class MarketplaceV3EventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.marketplace.marketplace_v3"
    self.group_id = "arena_marketplace_v3"

    def process(message)
      Rails.logger.info "Going to process a marketplace v3 event"

      parsed_message = JSON.parse(message.value)

      MarketplaceV3EventJob.perform_async(parsed_message)
    end
  end
end
