FactoryBot.define do
  factory :reward, class: "UserActivities::Reward" do
    user_activity

    trait :prizes do
      source { "prizes" }
    end

    trait :rewards do
      source { "rewards" }
    end
  end
end
