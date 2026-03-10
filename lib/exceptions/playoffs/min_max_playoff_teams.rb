module Playoffs
  class MinMaxPlayoffTeams < StandardError
    def initialize(min_teams, max_teams, current_number)
      @min_teams = min_teams
      @max_teams = max_teams
      @current_number = current_number
    end

    def to_s
      "The number of teams for this playoff should be between #{@min_teams} and #{@max_teams}, and there are #{@current_number}"
    end
  end
end
