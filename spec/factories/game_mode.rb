FactoryBot.define do
  factory :game_mode, class: "GameMode" do
    name { Faker::Name.unique.name }
    total_prize_pool { rand(1000) }
    prize_pool_realfevr_share { rand(1000) }
    prize_pool_winner_share { rand(1000) }
    compatible_ticket_ids { [1, 2, 3] }
    active { true }
    background_image_url { "http://background_image_url" }
    ticket_factory_contract_address { "0x#{SecureRandom.hex}" }
    min_xp_level { nil }
    max_xp_level { nil }
    erc20_name_alt { nil }
    erc20_name { "FEVR" }
  end
end
