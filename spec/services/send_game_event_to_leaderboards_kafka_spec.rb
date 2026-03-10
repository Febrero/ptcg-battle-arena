require "rails_helper"

RSpec.describe SendGameEventToLeaderboardsKafka do
  let(:game_event) do
    {"GameId" => "ABCD_1661271420_0",
     "GameStartTime" => 1661271420142,
     "GameEndTime" => 1661272020142,
     "GameDuration" => 600000,
     # ...
     "Players" => [{
       "WalletAddr" => "0xQweRty",
       # ...
       "UserId" => "12345",
       "CreatedAt" => (Time.now - 1.week).to_i
     },
       {
         "WalletAddr" => nil,
         # ...
         "UserId" => "67890",
         "CreatedAt" => (Time.now - 2.week).to_i
       }]}
  end

  it "should remove players with a nil wallet_addr from the event posted to kafka" do
    allow(KafkaIntegration::Producer).to receive(:deliver)

    subject.call(game_event)

    kafka_event = game_event.dup

    kafka_event["Players"] = kafka_event["Players"].delete_if { |p| p["WalletAddr"].nil? }

    expect(KafkaIntegration::Producer).to have_received(:deliver).with(kafka_event.to_json, topic: "events.leaderboards.battle_arena").once
  end
end
