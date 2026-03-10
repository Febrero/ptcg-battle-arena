module Playoffs
  module RoundsTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def total_rounds(n_teams = nil)
      teams_count = n_teams || teams.count
      tournament_format = Playoff::TOTAL_TEAMS_FORMAT
      tournament_teams_slots = tournament_format.detect { |b| b >= teams_count }
      tournament_format.index(tournament_teams_slots) + 1
    end

    def round_games(round = nil)
      round ||= current_round

      games_info = []
      brackets.where(round: round).order(current_bracket: :asc).each do |bracket|
        teams = bracket.teams
        team1 = teams[0]&.wallet_addr
        team2 = teams[1]&.wallet_addr

        player1_registration_timestamp = teams[0]&.created_at.to_i
        player2_registration_timestamp = teams[1]&.created_at.to_i

        games_info << {
          current_bracket: bracket.current_bracket,
          current_bracket_id: bracket.id.to_s,
          player1: team1,
          player2: team2,
          player1_registration_timestamp: player1_registration_timestamp,
          player2_registration_timestamp: player2_registration_timestamp
        }
      end
      games_info
    end

    def generate_rounds
      reload
      brackets.first.round.times do |r_number|
        rounds.build(number: (r_number + 1), duration: default_round_duration)
      end
      save!
    end
  end
end
