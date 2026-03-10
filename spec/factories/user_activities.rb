FactoryBot.define do
  factory :user_activity, class: "UserActivity" do
    wallet_addr { "0x123" }
  end
end
