FactoryBot.define do
  factory :playoffs_bracket, class: "Playoffs::Bracket" do
    current_bracket { 1 }
    next_bracket { 2 }
    next_bracket_id { "next_bracket_id" }
    round { 1 }
    teams_ids { ["team1_id", "team2_id"] }
    association :playoff, factory: :playoff
  end
end
