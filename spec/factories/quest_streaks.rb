FactoryBot.define do
  factory :quest_streak, class: GameType::QuestStreak do
    association :profile, factory: :quest_profile
    count { Faker::Number.number(digits: 2) }
    end_date { Faker::Time.between(from: DateTime.now, to: DateTime.now + 7) }
    claims { [] }
  end
end
