FactoryBot.define do
  factory :survival_player, class: "SurvivalPlayer" do
    wallet_addr { "0x#{SecureRandom.hex}" }

    survival

    active_entry_id { nil }

    entries {
      FactoryBot.build_list(:entry, 2) do |entry, i|
        if i == 1
          entry.levels_completed = 6
          entry.closed = true
          entry.closed_at = Time.now
        end
      end
    }
  end

  factory :entry, class: "SurvivalPlayers::Entry" do
    levels_completed { 4 }
    ticket_id { 12345 }
    ticket_submitted_at { Time.now }
    closed { false }
    closed_at { nil }
    games_ids { [] }
  end
end
