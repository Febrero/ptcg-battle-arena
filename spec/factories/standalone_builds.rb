FactoryBot.define do
  factory :standalone_build, class: "StandaloneBuild" do
    sequence(:version) { |n| "1.1.1.#{n}" }
    exe_download_url { "http://google.com" }
    dmg_download_url { "http://google.com" }

    trait :public do
      visibility { "public" }
    end

    trait :testers do
      visibility { "testers " }
    end

    trait :internal do
      visibility { "internal" }
    end
  end
end
