FactoryBot.define do
  factory :deck, class: "Deck" do
    wallet_addr { "0x1231231231231231231231231231231231231231" }
    name { Faker::Name.unique.name[0..13] }
    nft_ids { [] }
    video_ids { [] }
    grey_card_ids { [] }

    trait :two_stars do
      stars { 2 }
      name { Faker::Name.unique.name[0..13] }
      flag_status { true }
      wallet_addr { "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2" }
      nfts_count { 38 }
      grey_cards_count { 12 }
      nft_ids { [8222, 42603, 53432, 79317, 104923, 149874, 181363, 182523, 186755, 190815, 190879, 208395, 242539, 251472, 267750, 304784, 366665, 366976, 401020, 455603, 461179, 464616, 470281, 472484, 480336, 480338, 480620, 480621, 481710, 486559, 486562, 517044, 524261, 553139, 579296, 581817, 646843, 651021] }
      grey_card_ids { [88, 6, 45, 129, 67, 151, 138, 40, 143, 77, 32, 100] }
      power { 650 }
    end
  end
end
