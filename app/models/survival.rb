class Survival < GameMode
  include AASM

  field :start_date, type: DateTime
  field :end_date, type: DateTime

  field :min_deck_tier, type: Integer
  field :max_deck_tier, type: Integer
  field :acceptance_rules, type: Hash
  field :levels_count, type: Integer

  has_many :survival_players, inverse_of: :survival, foreign_key: :survival_id, primary_key: :uid

  embeds_many :stages, class_name: "Survivals::Stage"

  validates :start_date, :levels_count, presence: true

  aasm column: :state do
    state :incoming, initial: true
    state :active
    state :closed
    state :archived

    event :open do
      transitions from: :incoming, to: :active
    end

    event :reopen do
      transitions from: :closed, to: :active
    end

    event :close do
      transitions from: :active, to: :closed, after: :finish_survival_players_streaks
    end

    event :archive do
      transitions from: :closed, to: :archived
    end
  end

  private

  def finish_survival_players_streaks
    # survival_players.where() #ASYNC
  end
end
