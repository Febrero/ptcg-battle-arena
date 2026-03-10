FactoryBot.define do
  factory :ticket_offer, class: "TicketOffer" do
    association :ticket
    quantity { rand(1..50) }
    wallet_addr { "0x6c2005f258d8d1ef92d0a1e86b68e884d1808fb2" }
    offered { false }
    tx_hash { Random.hex }
  end
end
