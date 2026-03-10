class AssistedGamerSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "wallet_addr", type: :value},
    {field: "ai_mode", type: :value},
    {field: "week_days_that_play", type: :array},
    {field: "day_hours_that_play", type: :int_array}
  ]

  def initialize(params)
    super(params, AssistedGamer)
  end

  def self.search(params, cooldown = false)
    possible_gamers =
      AssistedGamer.where(
        "$expr" => {"$lt" => ["$todays_total_games_played", "$max_daily_games"]},
        :day_hours_that_play => Time.now.hour,
        :week_days_that_play => Date.today.strftime("%A")
      )
    possible_gamers = possible_gamers.where(:last_selected_at.lt => 30.minutes.ago) if cooldown
    possible_gamers.select { |g| !g.valid_deck(params[:deck_stars].to_i).nil? }.sample
  end
end
