class Game
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include AASM
  field :game_id, type: String
  field :game_log_id, type: String
  field :game_mode_id, type: Integer
  field :match_type, type: String
  field :season, type: Integer
  field :game_start_time, type: Integer
  field :game_end_time, type: Integer
  field :game_duration, type: Integer
  field :penalty_shootout, type: Boolean
  field :golden_goal, type: Boolean
  field :overtime, type: Boolean
  field :round_number, type: Integer
  field :turn_number, type: Integer
  field :applied_xp_rules, type: Hash
  field :players_wallet_addresses, type: Array
  field :winner, type: String
  field :any_player_resigned, type: Boolean
  field :tiebreaker_criteria, type: String

  field :game_end_reason, type: String

  aasm column: :state, timestamps: true do
    state :game_start_log
    state :game_end_log
    state :correction
  end

  field :state, type: String

  index({game_id: 1}, {name: "game_id_index", unique: true, background: true})
  index({state: 1}, {name: "state_index", background: true, sparse: true})
  index({game_start_time: 1}, {name: "game_start_time_index", background: true})
  index({game_mode_id: 1}, {name: "game_mode_id_index", background: true})

  validates :game_id, presence: true, uniqueness: true
  validates :match_type, :game_log_id, :game_start_time, presence: true

  has_many :players, class_name: "GamePlayer"

  def to_original_request
    game_details = {"Players" => []}

    [:game_id, :game_log_id, :match_type, :season, :game_start_time, :game_end_time,
      :game_duration, :penalty_shootout, :golden_goal, :overtime, :round_number, :turn_number].each do |field|
        game_details[field.to_s.camelize] = send(field)
      end

    game_details["GameMode"] = game_mode.try(:_type) || "Arena"
    game_details["GameModeId"] = game_mode_id

    players.each do |player|
      player_hash = [:wallet_addr, :deck_id, :ticket_id, :ticket_amount,
        :outcome, :goals_scored, :goals_conceded, :killcount,
        :hattricks, :saves, :deck_power, :deck_level, :rank_before_game,
        :resigned, :prize_amount, :prize_type].each_with_object({}) do |field, hash|
        hash[field.to_s.camelize] = player.send(field)
      end

      game_details["Players"] << player_hash
    end

    game_details
  end

  def self.match_count(match_type, game_mode_id = nil)
    Rails.cache.fetch("GameMatchCount/#{match_type}/#{game_mode_id}", expires_in: 3.minutes) do
      where(match_type: match_type, game_mode_id: game_mode_id).count
    end
  end

  def game_mode
    GameMode.where(uid: game_mode_id).first
  end

  def arena_game?
    game_mode.instance_of?("Arena")
  end

  def survival_game?
    game_mode.instance_of?("Survival")
  end
end
