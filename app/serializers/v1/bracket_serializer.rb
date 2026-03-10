module V1
  class BracketSerializer < ActiveModel::Serializer
    attributes :current_bracket, :next_bracket, :round, :teams_ids, :teams_info, :winner_team_id, :winner_team_name, :goals_scored, :winner_selected_by_system, :final_round

    def teams_info
      object.teams_info(true)
    end

    def final_round
      object.playoff.total_rounds
    end

    def winner_team_name
      object.winner_team_name
    end
  end
end
