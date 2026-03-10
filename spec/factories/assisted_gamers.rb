FactoryBot.define do
  factory :assisted_gamer, class: "AssistedGamer" do
    wallet_addr { "0x6c2005f258d8D1EF92D0A1E86b68e884d1808fb2" }
    week_days_that_play { Date::DAYNAMES }
    day_hours_that_play { (0..23).to_a }
    max_daily_games { 20 }
    todays_total_games_played { 0 }
    ai_mode { "Ari" }
  end
end
