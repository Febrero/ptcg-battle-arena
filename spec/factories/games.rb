FactoryBot.define do
  factory :game, class: "Game" do
    sequence(:game_id) { |n| n }
    game_log_id { "game-log-#{Time.now.strftime("%Y-%m-%d")}-#{game_id}" }

    pvp

    trait :pve do
      match_type { "PVE" }
      game_mode_id { -2 }
    end

    trait :pvp do
      match_type { "PVP" }
      game_mode_id { -1 }
    end

    trait :arena do
      match_type { "Arena" }
      game_mode_id { create(:arena).uid }
    end

    trait :survival do
      match_type { "Survival" }
      game_mode_id { create(:survival).uid }
    end

    game_start_time { Time.now.to_f * 1000 }
    game_end_time { (Time.now + 10.minutes).to_f * 1000 }
    game_duration { 10.minutes.to_f * 1000 }

    penalty_shootout { false }
    golden_goal { false }
    overtime { false }

    trait :with_penalties do
      penalty_shootout { true }
    end

    trait :with_golden_goal do
      golden_goal { true }
    end

    trait :with_overtime do
      overtime { true }
    end

    # players do
    #   FactoryBot.build_list(:player, 2) do |record, i|

    #     if i == 2
    #       record.outcome = "loss"
    #       record.goals_scored = 1
    #       record.goals_conceded = 2
    #     end
    #   end
    # end
  end
end
