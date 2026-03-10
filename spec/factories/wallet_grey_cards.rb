FactoryBot.define do
  factory :wallet_grey_card, class: "WalletGreyCard" do
    wallet_addr { "0x6c2005f258d8d1ef92d0a1e86b68e884d1808fb2" }
    rarity { %w[Common Special Epic Legendary Unique].sample }
    player_name { Faker::Name.unique.name }
    drop { "FE" }
    position { %w[Goalkeeper Defender Midfielder Forward].sample }
    defense { rand(20) }
    attack { rand(20) }
    stamina { rand(20) }
    ball_stopper { false }
    super_sub { true }
    man_mark { 2 }
    enforcer { false }
    inspire { "" }
    captain { "" }
    long_passer { false }
    box_to_box { true }
    dribbler { false }
    grey_card_id { 1 }
  end
end
