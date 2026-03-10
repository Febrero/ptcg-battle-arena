FactoryBot.define do
  factory :card_offer, class: "CardOffer" do
    wallet_addr { "0x70F657164e5b75689b64B7fd1fA275F334f28e18" }
    quantity { 1 }
    card_type { "grey_card" }
    offer_detail { {cards: [uid: GreyCard.first.uid]} }
    sequence(:reward_key) { |n| "REWARD::XPTO::#{n}" }
    source { "reward" }
    delivered { false }
  end
end
