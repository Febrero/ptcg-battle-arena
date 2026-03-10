require "rails_helper"

RSpec.describe Survivals::SendStreakEventToKafka do
  let(:survival_event) do
    {
      GameId: nil,
      GameMode: "Survival",
      GameModeId: nil,
      MatchType: "Survival",
      Season: nil,
      GameStartTime: (Time.now.to_i * 1000),
      Players: []
    }
  end

  before do
    create(:season)
  end

  it "should finished the streak of a given number of survival players (based on their ids)" do
    allow(KafkaIntegration::Producer).to receive(:deliver)

    survival_player = create(:survival_player, entries: [])
    survival_player.begin_streak(123)
    prize_amount = 10
    prize_type = "fevr"
    subject.call(survival_player, prize_amount, prize_type)

    kafka_event = survival_event.merge!({
      GameId: "sequence-#{survival_player.active_entry_id}-#{survival_player.wallet_addr}",
      GameModeId: survival_player.survival_id,
      Season: Season.currently_active.first.try(:uid),
      Players: [
        {
          WalletAddr: survival_player.wallet_addr,
          Sequence: survival_player.active_entry.levels_completed,
          PrizeAmount: prize_amount,
          PrizeType: prize_type
        }
      ]
    })

    expect(KafkaIntegration::Producer).to have_received(:deliver).with(kafka_event.to_json, topic: "events.leaderboards.battle_arena").once
  end
end
