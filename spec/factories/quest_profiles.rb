FactoryBot.define do
  factory :quest_profile, class: GameType::QuestProfile do
    wallet_addr { Faker::Blockchain::Bitcoin.address }
    association :quest, factory: :quest

    factory :quest_profile_with_streaks do
      transient do
        streak_count { 3 }
      end

      after(:create) do |quest_profile, evaluator|
        create_list(:quest_streak, evaluator.streak_count, profile: quest_profile)
      end
    end
  end
end
