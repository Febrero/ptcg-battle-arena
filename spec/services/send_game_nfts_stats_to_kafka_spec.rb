require "rails_helper"
RSpec.describe SendGameNftsStatsToKafka, type: :service do
  describe "#call" do
    let(:game_details) do
      {
        "GameId" => "example_game_id",
        "Players" => [
          {"WalletAddr" => "player1_wallet"},
          {"WalletAddr" => nil},
          {"WalletAddr" => "player2_wallet"}
        ]
      }
    end

    before do
      allow(Rails.logger).to receive(:info)
      allow(KafkaIntegration::Producer).to receive(:deliver)
    end

    it "logs a message indicating the sending of game Nfts stats to Kafka" do
      expect(Rails.logger).to receive(:info).with("Sending game nfts stats to kafka for game: #{game_details["GameId"]}")

      subject.call(game_details)
    end

    it 'delivers valid player data to the "events.nfts_stats.battle_arena" topic' do
      expect(KafkaIntegration::Producer).to receive(:deliver).with({"WalletAddr" => "player1_wallet", "GameId" => game_details["GameId"]}.to_json, topic: "events.nfts_stats.battle_arena")
      expect(KafkaIntegration::Producer).to receive(:deliver).with({"WalletAddr" => "player2_wallet", "GameId" => game_details["GameId"]}.to_json, topic: "events.nfts_stats.battle_arena")

      subject.call(game_details)
    end

    it "ignores game data for players without WalletAddr" do
      expect(KafkaIntegration::Producer).not_to receive(:deliver).with({"WalletAddr" => nil, "GameId" => game_details["GameId"]}.to_json, topic: "events.nfts_stats.battle_arena")

      subject.call(game_details)
    end
  end
end
