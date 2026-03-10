class AssistedGamer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include AssistedGamerValidations

  AI_MODES = ["Ari", "Bex", "Clyde"]

  field :wallet_addr, type: String
  field :week_days_that_play, type: Array, default: []
  field :day_hours_that_play, type: Array, default: []
  field :max_daily_games, type: Integer, default: 5
  field :todays_total_games_played, type: Integer, default: 0
  field :last_selected_at, type: DateTime, default: 1.year.ago
  # Expertise of the bot
  field :ai_mode, type: String

  validates :wallet_addr, :week_days_that_play, :day_hours_that_play, :ai_mode, presence: true

  index({wallet_addr: 1}, {unique: true, name: "wallet_addr_index", background: true})

  def valid_deck(stars)
    Deck.where(wallet_addr: wallet_addr, flag_status: true, stars: stars).to_a.sample
  end

  def profile
    Profile.find(wallet_addr)
  end
end
