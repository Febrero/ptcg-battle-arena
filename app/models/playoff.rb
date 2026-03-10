class Playoff < ::GameMode
  # @!parse include Playoffs::PrizesTrait
  # @!parse include Playoffs::RoundsTrait
  # @!parse include Playoffs::BracketsTrait
  # @!parse include Playoffs::ValidationTrait
  # @!parse include Playoffs::ScheduleTrait
  # @!parse include Playoffs::RollbackTrait
  include AASM
  include Playoffs::PrizesTrait
  include Playoffs::RoundsTrait
  include Playoffs::BracketsTrait
  include Playoffs::ValidationTrait
  include Playoffs::ScheduleTrait
  include Playoffs::RollbackTrait

  TOTAL_TEAMS_FORMAT = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
  THRESHOLD_MULTIPLIER_NEXT_SLOT = 0.6
  TIEBREAKER_PERCENTAGE_PRIZE_SLOT = 34.0

  field :open_date, type: DateTime
  field :open_timeframe, type: Integer, default: 10
  field :pregame_timeframe, type: Integer, default: 10
  field :default_round_duration, type: Integer, default: 30
  field :min_deck_tier, type: Integer
  field :max_deck_tier, type: Integer
  field :min_teams, type: Integer, default: 4
  field :max_teams, type: Integer
  field :current_round, type: Integer, default: 1
  field :winner_team_id, type: String
  field :prizes_generated, type: Boolean, default: false
  field :automatic_advance, type: Boolean, default: true
  field :max_wait_minutes_to_join, type: Integer, default: 5
  field :spend_ticket, type: Boolean, default: true
  field :automatic_prize_distribution, type: Boolean, default: true
  field :allow_only_wallets_in_whitelist, type: Boolean, default: false  # if true, only wallets in whitelist can join white list name should be playoff_#{playoff_uid}
  field :erc20_rewards_first_image_url, type: String
  field :erc20_rewards_second_image_url, type: String
  field :erc20_rewards_third_image_url, type: String
  field :erc20_rewards_default_image_url, type: String
  field :canceled_at, type: DateTime
  field :finished_at, type: DateTime
  field :has_custom_prize, type: Boolean, default: false
  field :multiplier_prize, type: Integer # 2, 4, 8, 16

  field :start_date, type: DateTime
  field :end_date, type: DateTime

  field :registered_profile_ids, type: Array, default: []

  # has_many :playoff_teams, inverse_of: :playoff, foreign_key: :playoff_id, primary_key: :uid
  has_many :teams, inverse_of: :playoff, foreign_key: :playoff_id, primary_key: :uid, class_name: "Playoffs::Team"
  has_many :brackets, inverse_of: :playoff, foreign_key: :playoff_id, primary_key: :uid, class_name: "Playoffs::Bracket"

  embeds_many :rounds, class_name: "Playoffs::Round"

  belongs_to :prize_config, primary_key: :uid, class_name: "Playoffs::PrizeConfig"

  validates :open_date, :min_teams, :max_teams, :min_deck_tier, :max_deck_tier, presence: true

  # validates :total_prize_pool, :erc20, :compatible_ticket_ids, presence: false # check this

  validate :validate_max_teams
  validate :validate_max_deck_tier

  # validate :validate_open_date, on: :create

  aasm column: :state, timestamps: true do
    state :upcoming, initial: true
    state :opened
    state :warmup
    state :ongoing
    state :troubleshooting
    state :finished
    state :archived
    state :canceled
    state :admin_pending
    state :manual_finished

    event :open do
      transitions from: :upcoming, to: :opened, after: :schedule_ongoing_event_change
    end

    event :pregame do
      transitions from: :opened, to: :warmup, after: :generate_started_playoff_data
    end

    event :start, after: :schedule_advance_round_event do
      transitions from: :warmup, to: :ongoing
    end

    event :cancel do
      transitions from: :opened, to: :canceled
    end

    event :finish, after: :on_finish do
      transitions from: [:admin_pending, :ongoing], to: :finished
    end

    event :continue do
      transitions from: [:troubleshooting], to: :ongoing
    end

    event :pause do
      transitions from: :ongoing, to: :troubleshooting
    end

    event :pending do
      transitions from: :ongoing, to: :admin_pending
    end

    event :archive do
      transitions from: [:finished, :canceled], to: :archived
    end

    event :manual_finish do
      transitions from: [:troubleshooting], to: :manual_finished
    end
  end

  index({open_date: 1}, {name: "open_date_index", background: true})
  index({start_date: 1}, {name: "start_date_index", background: true, sparse: true})
  index({end_date: 1}, {name: "end_date_index", background: true, sparse: true})

  def profiles_info(search_profile_id)
    expires_in = 2.minutes
    profiles_hash = Digest::SHA256.hexdigest(registered_profile_ids.join(","))

    profiles_info = Rails.cache.fetch("Playoffs::#{uid}::ProfilesFromMarketplaceApi::#{profiles_hash}", expires_in: expires_in) do
      profile_lite_by_id = {}
      registered_profile_ids.each_slice(100) do |batch_profile_ids|
        profile_lite_by_id.merge!(GetProfilesByIds.call(batch_profile_ids))
      end

      profile_lite_by_id.each do |profile_id, lite_info|
        Rails.cache.write("Playoffs::#{uid}::ProfileLiteInfo::#{profile_id}", lite_info, expires_in: expires_in)
      end
      profile_lite_by_id
    end

    profiles_info[search_profile_id.to_s]
  end

  def on_finish
    return if admin_only

    generate_user_activity
    Playoffs::GeneratePrizes.call(uid)
    Playoffs::RegisterPrizeOnTeamAndSendToLeaderboards.call(uid)
    Playoffs::GeneratePositions.call(uid)
  end

  def should_spend_ticket?
    spend_ticket
  end

  def generate_user_activity
    teams.each do |team|
      UserActivity.create(
        wallet_addr: team.wallet_addr,
        event_info: {team_id: team.id.to_s},
        source: self,
        event_date: timeframes[:end_date],
        season_uid: Season.currently_active.first.uid
      )
    end
  end

  def timeframes
    timeframes_per_round = []
    round_total_timeframes = (open_date + (open_timeframe + pregame_timeframe).minutes)
    # round_total_timeframes = (open_date + open_timeframe.minutes)

    n_teams = teams.count
    n_rounds = (n_teams < min_teams) ? total_rounds(min_teams) : total_rounds(n_teams)

    (1..n_rounds).each do |round|
      advance_time = rounds.where(number: round)&.first&.duration || default_round_duration
      timeframes_per_round << round_total_timeframes

      round_total_timeframes += advance_time.minutes
    end

    final_game_ended = round_total_timeframes

    {
      registration_start: open_date,
      registration_end: open_date + open_timeframe.minutes,
      start_date: open_date + open_timeframe.minutes + pregame_timeframe.minutes,
      start_dates_per_round: timeframes_per_round,
      end_date: final_game_ended
    }
  end

  private

  def generate_started_playoff_data
    validate_number_of_teams
    generate_brackets
    generate_rounds
  end
end
