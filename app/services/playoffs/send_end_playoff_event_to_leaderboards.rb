module Playoffs
  class SendEndPlayoffEventToLeaderboards < ApplicationService
    def call playoff_uid, wallet_addr, prize_amount, prize_type, sequence
      Rails.logger.info "Sending  streak event to kafka for playoff: #{playoff_uid}"

      playoff = Playoff.where(uid: playoff_uid).first

      event_details = {
        GameId: "playoff-#{playoff.uid}-#{wallet_addr}",
        GameMode: "Playoff",
        GameModeId: playoff_uid,
        MatchType: "Playoff",
        Season: Season.currently_active.first.try(:uid),
        GameStartTime: (playoff.timeframes[:start_date].to_i * 1000), # should be sent in milisecond
        Players: [
          {
            WalletAddr: wallet_addr,
            Sequence: sequence,
            PrizeAmount: prize_amount,
            PrizeType: prize_type,
            PlayoffCount: 1
          }
        ]
      }

      KafkaIntegration::Producer.deliver(event_details.to_json, topic: "events.leaderboards.battle_arena")
    end
  end
end
