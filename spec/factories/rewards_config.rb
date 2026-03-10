FactoryBot.define do
  factory :reward_config, class: "RewardsConfig" do
    win

    trait :win do
      achievement_type { "win" }
      achievement_value { 10 }
      desc { "Game won" }
    end

    trait :play do
      achievement_type { "play" }
      achievement_value { 20 }
      desc { "Game played" }
    end

    trait :score_5plus do
      achievement_type { "score_5plus" }
      achievement_value { 5 }
      desc { "Scored more than 4 goals" }
    end

    trait :clean_sheet do
      achievement_type { "clean_sheet" }
      achievement_value { 5 }
      desc { "Kept a cleansheet" }
    end

    trait :hattrick do
      achievement_type { "hattrick" }
      achievement_value { 5 }
      desc { "Scored a hattrick" }
    end

    trait :underdog do
      achievement_type { "underdog" }
      achievement_value { 5 }
      desc { "Game won with the least powerfull deck" }
    end
  end
end
