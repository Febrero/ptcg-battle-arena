FactoryBot.define do
  factory :playoff, parent: :game_mode, class: "Playoff" do
    state { "opened" }
    open_date { DateTime.now }
    open_timeframe { 10 }
    min_deck_tier { 1 }
    max_deck_tier { 1 }
    min_teams { 4 }
    max_teams { 16 }
    default_round_duration { 30 }
    compatible_ticket_ids { ["1"] }
    ticket_factory_contract_address { "0x123" }
    ticket_amount_needed { 1 }
    spend_ticket { true }
    allow_only_wallets_in_whitelist { false }

    trait :upcoming do
      state { "upcoming" }
    end

    trait :opened do
      state { "opened" }
    end

    trait :warmup do
      state { "warmup" }
    end

    trait :ongoing do
      state { "ongoing" }
    end

    trait :finished do
      state { "finished" }
    end

    trait :archived do
      state { "archived" }
    end

    trait :canceled do
      state { "canceled" }
    end

    trait :admin_pending do
      state { "admin_pending" }
    end

    trait :troubleshooting do
      state { "troubleshooting" }
    end

    trait :with_teams do
      transient do
        teams_count { 6 }
      end

      after(:create) do |playoff, evaluator|
        create_list(:playoffs_team, evaluator.teams_count, playoff: playoff)
      end
    end

    trait :with_ticket_config do
      before(:create) do |playoff, evaluator|
        ticket = create(:ticket)

        playoff.compatible_ticket_ids = [ticket.bc_ticket_id]
        playoff.ticket_factory_contract_address = ticket.ticket_factory_contract_address
      end
    end

    association :prize_config, factory: :prize_config
  end
end
