module Playoffs
  class GeneratePositions
    include Callable

    attr_reader :playoff, :brackets, :last_round, :final_bracket, :teams_info, :positions

    def initialize(playoff_uid)
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @brackets = playoff.brackets.order_by(round: :desc).to_a
      @last_round = brackets[0].round
      @final_bracket = brackets[0]
      @teams_info = Hash.new { |h, k| h[k] = {lost_to: nil, last_round: nil} }
      @positions = {}
    end

    def call
      # Populate the mapping with information about each team
      find_teams_info
      finalists
      rest_positions
      # save_positions
      positions
    end

    # map for each team the team that they lost to and the round that they lost
    # @note: example of data
    # {"65958e5107709e001aa4a060"=>{:lost_to=>"65958e5107709e001aa4a05f", :last_round=>4},
    #  "65958e5107709e001aa4a061"=>{:lost_to=>"65958e5107709e001aa4a060", :last_round=>3},
    #  "65958e5107709e001aa4a05e"=>{:lost_to=>"65958e5107709e001aa4a05f", :last_round=>3},
    #  "65958e5107709e001aa4a066"=>{:lost_to=>"65958e5107709e001aa4a061", :last_round=>2},
    #  "65958e5107709e001aa4a062"=>{:lost_to=>"65958e5107709e001aa4a060", :last_round=>2},
    #  "65958e5107709e001aa4a05c"=>{:lost_to=>"65958e5107709e001aa4a05e", :last_round=>2},
    #  "65958e5107709e001aa4a05d"=>{:lost_to=>"65958e5107709e001aa4a05f", :last_round=>2},
    #  "65958e5107709e001aa4a064"=>{:lost_to=>"65958e5107709e001aa4a066", :last_round=>1},
    #  "65958e5107709e001aa4a063"=>{:lost_to=>"65958e5107709e001aa4a061", :last_round=>1},
    #  "65958e5107709e001aa4a065"=>{:lost_to=>"65958e5107709e001aa4a062", :last_round=>1}}

    def find_teams_info
      brackets.each do |bracket|
        winner = bracket.winner_team_id
        loser = bracket.teams_ids.find { |id| id != winner }

        if loser
          @teams_info[loser][:lost_to] = winner
          @teams_info[loser][:last_round] = bracket.round
        end
      end
    end

    def finalists
      winner = teams_info.first[1][:lost_to]
      second = teams_info.select { |k, v| v[:lost_to] == winner }.keys.first

      @positions[winner] = 1
      @positions[second] = 2

      save_position winner, 1
      save_position second, 2
    end

    def rest_positions
      current_position = 2
      (last_round - 1).downto(1).each do |round|
        # get teams for each round that we are iterate
        round_teams = teams_info.select { |k, v| v[:last_round] == round }.keys

        # sort teams by the position of the team that they lost to
        round_teams.sort_by! do |team_id|
          @positions[teams_info[team_id][:lost_to]]
        end

        # iterate each team of round and asign position
        round_teams.each do |team_id|
          current_position += 1
          @positions[team_id] = current_position
          save_position team_id, current_position
        end
      end
    end

    def save_position team_id, position
      team = playoff.teams.find(team_id)
      team.position = position
      team.save
    end

    def save_positions
      positions.each do |team_id, position|
        save_position team_id, position
      end
    end
  end
end
