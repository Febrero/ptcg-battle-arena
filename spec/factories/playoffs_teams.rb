FactoryBot.define do
  factory :playoffs_team, class: "Playoffs::Team" do
    wallet_addr { "0x#{SecureRandom.hex}" }
    wallet_addr_downcased { wallet_addr.downcase }
    profile_id { "profile_id" }
    current_bracket_id { "bracket_id" }
    association :playoff, factory: :playoff
  end
end
