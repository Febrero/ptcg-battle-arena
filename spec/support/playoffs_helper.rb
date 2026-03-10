module PlayoffsHelper
  def simulate(playoff_uid, random = true, pre_selected_team_id = nil, always_win = true)
    playoff = Playoff.find_by(uid: playoff_uid)

    playoff_rounds = playoff.rounds.count
    (1..playoff_rounds).each do |round|
      all_brackets_played_in_round = false
      until all_brackets_played_in_round
        bracket = playoff.reload.brackets.where(round: round, winner_team_id: nil).first

        if !bracket
          all_brackets_played_in_round = true
          next
        end
        teams = bracket.teams
        winner_team = if pre_selected_team_id.present?
          selected_team_index = teams.find_index { |team| team.id == pre_selected_team_id }
          if selected_team_index.present?
            always_win ? teams[selected_team_index] : teams[(selected_team_index + 1) % teams.count]
          else
            random ? teams.sample : teams[0]
          end
        else
          random ? teams.sample : teams[0]
        end
        winner_team_id = winner_team.id.to_s
        bracket.winner_team_id = winner_team_id
        bracket.save(validate: false)

        nextbracket = playoff.brackets.where(current_bracket: bracket.next_bracket).first
        if nextbracket
          nextbracket.teams_ids[nextbracket.previous_brackets.find_index(bracket.current_bracket)] = winner_team_id
          nextbracket.save(validate: false)
        else
          playoff.winner_team_id = winner_team_id
          playoff.save(validate: false)
        end

      end
    end
    playoff.state = "finished"
    playoff.save
  end
end
