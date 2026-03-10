FactoryBot.define do
  factory :game_player, class: "GamePlayer" do
    wallet_addr { "0x#{SecureRandom.hex}" }

    game

    deck_id { SecureRandom.hex.to_s }
    ticket_id { "0" }
    ticket_amount { "0" }

    outcome { "win" }
    goals_scored { 2 }
    goals_conceded { 1 }
    killcount { Faker::Number.between(from: 0, to: 10) }
    hattricks { Faker::Number.between(from: 0, to: 1) }
    saves { Faker::Number.between(from: 0, to: 30) }
    deck_power { 100 }
    deck_level { 1 }
    rank_before_game { 0 }

    winner { true }

    trait :loser do
      winner { false }
    end
  end
end
