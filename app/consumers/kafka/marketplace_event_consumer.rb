module Kafka
  class MarketplaceEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.marketplace.marketplace"
    self.group_id = "arena_marketplace"

    def process(message)
      Rails.logger.info "Going to process a marketplace event"

      parsed_message = JSON.parse(message.value)

      MarketplaceEventJob.perform_async(parsed_message)
    end
  end
end
