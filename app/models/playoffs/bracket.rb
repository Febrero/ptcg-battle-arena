module Playoffs
  class Bracket
    include Mongoid::Document
    include AASM

    field :current_bracket, type: Integer
    field :next_bracket, type: Integer
    field :next_bracket_id, type: String
    field :previous_brackets, type: Array, default: []
    field :round, type: Integer
    field :teams_ids, type: Array, default: []
    field :goals_scored, type: Array, default: []
    field :game_id, type: String
    field :winner_team_id, type: String
    field :winner_selected_by_system, type: Boolean, default: false
    field :game_end_reason, type: String
    field :history_rollback, type: Array, default: []

    belongs_to :playoff, primary_key: :uid, class_name: "Playoff"

    index({playoff_id: 1}, {name: "playoff_id_index", background: true})
    index({round: 1}, {name: "round_index", background: true})

    def reset
      if winner_team_id
        current_state = {
          timestamp: Time.now.to_i,
          old_values: {
            teams_ids: teams_ids,
            goals_scored: goals_scored,
            game_id: game_id,
            winner_team_id: winner_team_id,
            winner_selected_by_system: winner_selected_by_system,
            game_end_reason: game_end_reason
          }
        }

        history_rollback << current_state

        teams.each do |team|
          if team.id != winner_team_id
            team.still_in_playoff = true
            team.ended_at = nil
            team.last_round = Playoffs::Team::LAST_ROUND_WHEN_IN_PLAYOFF
            team.prize_amount = {}
            team.save
          end
        end
      end

      self.teams_ids = [nil, nil] if round > 1
      self.goals_scored = []
      self.game_id = nil
      self.winner_team_id = nil
      self.winner_selected_by_system = false
      self.game_end_reason = nil
      save
    end

    def teams
      teams_ids&.map do |team_id|
        if team_id
          Playoffs::Team.find(team_id)
        end
      end
    end

    def teams_info(with_extra_info = false, teams_by_id = {})
      teams_ids&.reverse&.map&.with_index do |team_id, index|
        if team_id
          team = teams_by_id[team_id] || Playoffs::Team.find(team_id)
          info = {
            id: team.id.to_s,
            game_id: game_id,
            wallet_addr: team.wallet_addr,
            name: team.name,
            goals_scored: goals_scored.reverse[index],
            registered_time: team.created_at.to_i
          }

          if with_extra_info
            info[:avatar_url] = team.avatar
            info[:xp_level] = team.xp_level
          end
          info
        end
      end
    end

    def winner_team_name
      winner_name = nil
      if winner_team_id
        team = Playoffs::Team.find(winner_team_id)
        winner_name = team.name
      end
      winner_name
    end
  end
end

# current_bracket: total_brackets,
# next_bracket: nil,
# teams: [],
# round
