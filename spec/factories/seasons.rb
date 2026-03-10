FactoryBot.define do
  factory :season, class: "Season" do
    sequence(:uid) { |n| n }
    name { Faker::Name.unique.name }
    start_date { (DateTime.now - 2.days).utc.to_i }
    active { true }
    trait :end_date do
      end_date { (DateTime.now + 30.days).utc.to_i }
      active { false }
    end
  end
end
