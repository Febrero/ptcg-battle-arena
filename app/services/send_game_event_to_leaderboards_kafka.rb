class SendGameEventToLeaderboardsKafka < ApplicationService
  def call game_details
    Rails.logger.info "Sending game event to kafka for game: #{game_details["GameId"]}"

    # Ignore game data for BOTs
    game_details["Players"] = game_details["Players"].delete_if { |p| p["WalletAddr"].blank? }

    KafkaIntegration::Producer.deliver(game_details.to_json, topic: "events.leaderboards.battle_arena")
  end
end
