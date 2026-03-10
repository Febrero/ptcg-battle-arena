# spec/factories/articles.rb
FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article Title #{n}" }
    sequence(:subtitle) { |n| "Article Subtitle #{n}" }
    sequence(:cover_image_url) { |n| "http://example.com/image#{n}.jpg" }
    sequence(:description) { |n| "Article Description #{n}" }
    active { false }
    start_date { 1.day.ago }
    end_date { 1.day.from_now }
    sequence(:position_order) { |n| n }

    trait :active do
      active { true }
    end

    trait :with_invalid_dates do
      start_date { 1.day.from_now }
      end_date { 1.day.ago }
    end
  end
end
