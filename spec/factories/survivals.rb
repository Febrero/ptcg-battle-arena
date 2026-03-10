FactoryBot.define do
  factory :survival, parent: :game_mode, class: "Survival" do
    start_date { Time.now - 10.days }
    end_date { Time.now + 10.days }

    incoming

    ticket_factory_contract_address { "0x1234" }

    min_deck_tier { 1 }
    max_deck_tier { 5 }

    levels_count { 7 }

    acceptance_rules {
      ActiveSupport::HashWithIndifferentAccess.new
    }

    trait :incoming do
      state { "incoming" }
    end

    trait :active do
      state { "active" }
    end

    trait :closed do
      state { "closed" }
    end

    trait :archived do
      state { "archived" }
    end

    stages {
      FactoryBot.build_list(:stage, 7) do |record, i|
        level = i + 1

        record.level = level
        record.prize_amount = level * 1000
        record.prize_type = :fevr
      end
    }
  end

  factory :stage, class: "Survivals::Stage" do
    level { 1 }
    prize_amount { 1000 }
    prize_type { :fevr }
  end
end
