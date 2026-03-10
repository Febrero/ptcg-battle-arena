FactoryBot.define do
  factory :splash_screen, class: "SplashScreen" do
    name { Faker::Name.unique.name }
    image_url { "https://google.com" }
    active { true }
  end
end
