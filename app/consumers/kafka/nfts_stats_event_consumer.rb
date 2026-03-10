module Kafka
  class NftsStatsEventConsumer < KafkaIntegration::Consumer
    subscribes_to "events.nfts_stats.battle_arena"
    self.group_id = "nfts_stats_events"

    def process(message)
      Rails.logger.info "Going to process a Nfts Stats event"

      parsed_message = JSON.parse(message.value)

      NftsStatsEventJob.perform_async(parsed_message)
    end
  end
end
