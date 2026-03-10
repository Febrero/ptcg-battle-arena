FactoryBot.define do
  factory :ticket, class: "Ticket" do
    sequence(:bc_ticket_id) { |n| n }
    name { Faker::Name.unique.name }
    description { Faker::Lorem.paragraph }
    base_price { rand(1000) }
    start_date { Time.now }
    expiration_date { Time.now + 1.day }
    sale_expiration_date { Time.now + 1.day }
    available_quantities { [1, 2, 3, 4, 5, 10, 20, 50, 100] }
    image_url { "http://image_url" }
    active { true }
    ticket_factory_contract_address { "0x#{SecureRandom.hex}" }
    game_mode { "arena" }
  end
end
