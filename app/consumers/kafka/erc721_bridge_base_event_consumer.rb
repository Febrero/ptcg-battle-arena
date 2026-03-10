module Kafka
  class Erc721BridgeBaseEventConsumer < KafkaIntegration::Consumer
    subscribes_to "smart_contracts.bridges.base_erc721"
    self.group_id = "arena_erc721_bridge_base"

    def process(message)
      Rails.logger.info "Going to process a erc721 bridge base event"

      parsed_message = JSON.parse(message.value)

      Erc721BridgeBaseEventJob.perform_async(parsed_message)
    end
  end
end
