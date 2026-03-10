FactoryBot.define do
  factory :ticket_bundle, class: "TicketBundle" do
    image_url { "https://google.com" }
    tickets_quantity { rand(1..10) }
    old_price { 1 }
    discount { 0.1 }
    final_price { 0.9 }
    name { "MEGACENAS" }
    slug { "mega-cenas" }
    order { 1 }
    sale_expiration_date { Time.now + 1.year }

    ticket
  end
end
