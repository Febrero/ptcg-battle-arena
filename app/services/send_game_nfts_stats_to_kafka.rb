class SendGameNftsStatsToKafka < ApplicationService
  def call game_details
    Rails.logger.info "Sending game nfts stats to kafka for game: #{game_details["GameId"]}"

    # Ignore game data for BOTs
    game_details["Players"].delete_if { |p| p["WalletAddr"].blank? }.each do |valid_player_hash|
      valid_player_hash["GameId"] = game_details["GameId"]

      KafkaIntegration::Producer.deliver(valid_player_hash.to_json, topic: "events.nfts_stats.battle_arena")
    end
  end
end
