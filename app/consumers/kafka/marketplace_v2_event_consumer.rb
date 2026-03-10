module Kafka
  class MarketplaceV2EventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.marketplace.marketplace_v2"
    self.group_id = "arena_marketplace_v2"

    def process(message)
      Rails.logger.info "Going to process a marketplace v2 event"

      parsed_message = JSON.parse(message.value)

      MarketplaceV2EventJob.perform_async(parsed_message)
    end
  end
end
