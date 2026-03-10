FactoryBot.define do
  factory :playoffs_round, class: "Playoffs::Round" do
    sequence(:number)
    duration { 30 }
    association :playoff, factory: :playoff
  end
end
