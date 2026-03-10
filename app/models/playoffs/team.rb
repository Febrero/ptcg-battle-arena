module Playoffs
  class Team
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Pagination

    LAST_ROUND_WHEN_IN_PLAYOFF = 1000

    field :wallet_addr, type: String
    field :wallet_addr_downcased, type: String
    field :profile_id, type: String
    field :current_bracket_id, type: String
    field :ticket_id, type: String
    field :ticket_amount, type: Integer, default: 1
    field :still_in_playoff, type: Boolean, default: true # field that retrive current state of the team in the playoff, if false the team is eliminated
    field :ended_at, type: DateTime
    field :last_round, type: Integer, default: LAST_ROUND_WHEN_IN_PLAYOFF
    field :prize_amount, type: Hash, default: {}
    field :name, type: String
    field :xp_level, type: Integer
    field :avatar, type: String

    belongs_to :playoff, primary_key: :uid, class_name: "Playoff"

    field :playoff_ends, type: DateTime
    field :prize_sequence, type: Integer, default: 0
    field :position, type: Integer

    validates :wallet_addr_downcased, uniqueness: {scope: :playoff_id}
    validate :validate_playoff_status, if: :new_record?
    validate :validate_playoff_max_teams, if: :new_record?

    index({playoff_id: 1}, {name: "playoff_id_index", background: true})
    index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
    index({wallet_addr_downcased: 1}, {name: "wallet_addr_downcased_index", background: true})
    index({current_bracket_id: 1}, {name: "current_bracket_id_index", background: true})
    index({playoff_ends: 1}, {name: "playoff_ends_index", background: true})
    index({still_in_playoff: 1}, {name: "still_in_playoff_index", background: true})
    index({ended_at: 1}, {name: "ended_at_index", background: true})
    index({last_round: 1}, {name: "last_round_index", background: true})
    index({position: 1}, {name: "position_index", background: true, sparse: true})
    index({xp_level: 1}, {name: "xp_level_index", background: true, sparse: true})

    index({profile_id: 1}, {name: "profile_id_index", background: true})

    def has_prize?
      (prize_amount[:amount] || 0.0) > 0.0
    rescue
      false
    end

    def current_bracket
      if !current_bracket_id.nil?
        return playoff.brackets.find(current_bracket_id)
      end

      nil
    end

    def validate_playoff_status
      if !playoff.opened?
        errors.add(:base, "Playoff is not open to receive teams")
      end
    end

    def validate_playoff_max_teams
      max_teams_allowed = playoff.max_teams || Playoff::TOTAL_TEAMS_FORMAT[-1]

      if playoff.reload.teams.count >= max_teams_allowed
        errors.add(:base, "The playoff is already with maximum of teams")
      end
    end

    def games
      @games ||= begin
        games_ids = brackets.map(&:game_id)

        Game.in(game_id: games_ids).order(game_start_time: :desc)
      end
    end

    def brackets
      @brackets ||= playoff.brackets.where(teams_ids: id.to_s)
    end

    def game_wins
      games.where(winner: wallet_addr).count
    end

    def total_wins
      (games.count < brackets.count) ? (game_wins + 1) : game_wins
    end

    def finish_playoff(round_where_finish, prize_amount)
      self.still_in_playoff = false
      self.ended_at = Time.now
      self.last_round = round_where_finish
      self.prize_amount = prize_amount
      save
    end
  end
end
