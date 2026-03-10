FactoryBot.define do
  factory :tutorial_progress, class: ::TutorialProgress do
    wallet = Faker::Blockchain::Ethereum.address

    wallet_addr { wallet }
    wallet_addr_downcased { wallet.downcase }
    completed { false }
    completion_date { nil }
  end

  factory :step, class: ::TutorialProgresses::Step do
    name { Faker::Name.first_name }
  end
end
