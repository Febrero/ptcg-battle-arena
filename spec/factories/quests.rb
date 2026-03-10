FactoryBot.define do
  factory :quest, class: GameType::Quest do
    uid { Faker::Number.unique.number(digits: 4) }
    type { "daily" }
    active { true }
    config {
      [
        {xp: 100, fevr: 1000, nft: {common: 1}},
        {xp: 200, nft: {common: 2}, ticket: {"1" => 1}, pack: {basic: 1}},
        {xp: 300, pack: {ultra: 2}}
      ]
    }
  end
end
