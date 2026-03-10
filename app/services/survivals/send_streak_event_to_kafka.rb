module Survivals
  class SendStreakEventToKafka < ApplicationService
    def call survival_player, prize_amount, prize_type
      Rails.logger.info "Sending survival streak event to kafka for survival_player: #{survival_player.id}"

      event_details = {
        GameId: "sequence-#{survival_player.active_entry_id}-#{survival_player.wallet_addr}",
        GameMode: "Survival",
        GameModeId: survival_player.survival_id,
        MatchType: "Survival",
        Season: Season.currently_active.first.try(:uid),
        GameStartTime: (Time.now.utc.to_i * 1000), # should be sent in milisecond
        Players: [
          {
            WalletAddr: survival_player.wallet_addr,
            Sequence: survival_player.active_entry.levels_completed,
            PrizeAmount: prize_amount,
            PrizeType: prize_type
          }
        ]
      }

      KafkaIntegration::Producer.deliver(event_details.to_json, topic: "events.leaderboards.battle_arena")
    end
  end
end
