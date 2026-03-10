module Playoffs
  class Drawer
    # Draw the playoff tree diagram for a given playoff_id
    def self.print_bracket(playoff)
      max_round = playoff.brackets.map(&:round).max
      bracket_structure = Array.new(max_round) { [] }
      diagram = ""

      # Group brackets by round
      playoff.brackets.each do |bracket|
        bracket_structure[bracket.round - 1] << bracket
      end

      # Build diagram for each round
      (1..max_round).each do |round|
        diagram += "\nRound #{round}:\n"
        diagram += "-" * 100 + "\n"
        brackets_in_round = bracket_structure[round - 1]

        brackets_in_round.each do |bracket|
          team1, team2 = bracket.teams.map(&:wallet_addr)
          team1 ||= "NIL"
          team2 ||= "NIL"

          diagram += "|" + "-" * 96 + "|" + "\n"
          diagram += "| Bracket #{bracket.current_bracket}: \n"
          diagram += "| Team 1: #{team1}\n"
          diagram += "| Team 2: #{team2}\n"
          if round > 1
            pp brackets_in_round
            pp bracket_structure[round - 2]
            prev_brackets = bracket_structure[round - 2].filter { |b| b.next_bracket == bracket.current_bracket }
            pp prev_brackets
            diagram += "| From: Bracket #{prev_brackets[0].current_bracket} vs Bracket #{prev_brackets[1].current_bracket}\n"
          end
          diagram += "|" + "-" * 96 + "|" + "\n"
        end
        diagram += "-" * 100 + "\n"
      end

      # Print final diagram
      puts diagram
    end
  end
end
