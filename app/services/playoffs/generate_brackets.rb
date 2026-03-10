# Bracket Generator
#
# This service has the responsability of generating the brackets for a playoff.
# A playoff should take into consideration the following  teams's format [4, 8, 16, 32, 64, 128, 256, 512, 1024]
# When generating the brackets the number of teams may not match the previous formats (can even be odd), in that
# case we will generate a tournament for the number of teams (given) rounded up to a valid format, filling the
# missing brackets's spots with nil:
#   - example: 5 teams -> tournament of 8 teams format
# The teams that are alocated to thos brackets are the oldest teams to be added to the playoff.
#
# The rounds definition is made top to bottom in order to have randomly assigned brackets to the winners, i.e.
# we first generate the final bracket, then, dynamically we generate the middle rounds, and at last we calculate
# the first rounds (with teams in them)
# the winner of bracket 1 can play the winner of bracket 3 instead of the one from bracket 2
#
module Playoffs
  class GenerateBrackets
    include Callable

    attr_reader :playoff, :teams, :output_logger,
      :teams_count, :tournament_format, :tournament_teams_slots, :bye_slots,
      :total_rounds, :bracket_number, :round_brackets, :previous_round_bracket_info

    def self.total_rounds(teams_count)
      tournament_format = Playoff::TOTAL_TEAMS_FORMAT
      tournament_teams_slots = tournament_format.detect { |b| b >= teams_count }
      tournament_format.index(tournament_teams_slots) + 1
    end

    def self.slots(teams_count)
      tournament_format = Playoff::TOTAL_TEAMS_FORMAT
      tournament_teams_slots = tournament_format.detect { |b| b >= teams_count }
      bye_slots = tournament_teams_slots - teams_count

      index = tournament_format.index(tournament_teams_slots)
      slot_prize = tournament_format[index]
      if bye_slots > 0
        slot_prize = tournament_format[index - 1]
        slot_prize = tournament_format[index] if ((teams_count - slot_prize).to_f / slot_prize) * 100.0 >= 25.0
      end
      slot_prize
    end

    def initialize(playoff_uid, output_logger = true)
      @playoff = Playoff.find_by(uid: playoff_uid)
      @teams = playoff.teams
      @output_logger = output_logger
    end

    def output(msg)
      if output_logger
        Rails.logger.info msg
      else
        puts msg
      end
    end

    def call
      output "Going to generate brackets for playoff: #{playoff.uid}"
      setup

      output "***************************************************************************************"

      output "Create BRACKET OF FINAL ..."

      output "and save info to previous brackets (Semifinals) with info of next_bracket (the final)  ..."
      # previous calculated brackets
      @previous_round_bracket_info = previous_info(create_final)

      ## Middle round(s) setup
      @round_brackets = 2 # the minimal for a middle round, if exist (would be semi-finals)

      create_middle_round_brackets

      create_initial_round
    end

    private

    def setup
      output "SETUP"
      @teams_count = teams.count
      output "TEAMS: #{teams_count}"
      @tournament_format = Playoff::TOTAL_TEAMS_FORMAT
      output "FORMATS AVAILABLE: #{tournament_format}"
      @tournament_teams_slots = tournament_format.detect { |b| b >= teams_count }
      raise "Invalid teams count" if tournament_teams_slots.nil?
      output "SLOTS FITS TO THIS PLAYOFF: #{tournament_teams_slots}"
      @bye_slots = tournament_teams_slots - teams_count
      # Calculate the number of rounds and the total brackets count
      # the addons 2 and 3 are to geenrate valid counters taken into consideration the formats available
      @total_rounds = tournament_format.index(tournament_teams_slots) + 1
      @bracket_number = tournament_format.sum { |slot_count| (slot_count < tournament_teams_slots) ? slot_count : 0 } + 1
      output "TOTAL ROUNDS: #{total_rounds}"
      output "TOTAL BRACKETS NECESSARY: #{bracket_number}"
      ## Final round setup (next_bracket non existant)
    end

    def create_final
      create_bracket(bracket_number, total_rounds)
    end

    def create_middle_round_brackets
      (total_rounds - 1).downto(2).each do |round|
        output "CREATE INFO TO ROUND #{round}  ..."
        round_bracket_info = []
        # create bracket per round
        round_brackets.times do
          @bracket_number -= 1
          output "CREATE BRACKET #{bracket_number} IN ROUND  #{round} ..."

          # get previous bracket
          next_bracket, next_bracket_id = get_previous_bracket

          # create current bracket in round
          round_bracket = create_bracket(bracket_number, round, next_bracket, next_bracket_id)

          next_bracket_info = playoff.brackets.where(current_bracket: next_bracket).first
          next_bracket_info.previous_brackets << bracket_number
          next_bracket_info.save!

          # save each bracket info for use in previous round
          round_bracket_info += previous_info(round_bracket)
        end

        @previous_round_bracket_info = round_bracket_info

        @round_brackets *= 2
      end
    end

    def randomize_teams sorted_teams_ids, number_bye_slots
      bye_slots_teams = sorted_teams_ids.slice(0, number_bye_slots)

      paired_teams = sorted_teams_ids.slice(bye_slots, sorted_teams_ids.count)

      bye_slots_teams.shuffle!
      paired_teams.shuffle!

      [bye_slots_teams, paired_teams]
    end

    def create_initial_round
      output "CREATE BRACKETS IN INITIAL ROUND ..."
      ## Initial round setup
      # sort the teams by their created date

      sorted_teams_ids = teams.sort_by(&:created_at).map { |t| t.id.to_s }

      bye_slot_teams, paired_teams = randomize_teams(sorted_teams_ids, @bye_slots)
      # make an distribution of brackets with bye slots and paired teams
      randomize_brackets = (Array.new((paired_teams.count / 2), 0) + Array.new(bye_slot_teams.count, 1)).shuffle!

      (tournament_teams_slots / 2).downto(1) do |idx|
        is_an_by_slot = randomize_brackets[idx - 1] == 1

        # if there is bye slot,s we are going to add to the the oldest teams otherwise
        # randomly selects 2 teams for this game
        output "PICK TEAMS TO MAKE BRACKET..."

        next_bracket, next_bracket_id = get_previous_bracket

        winner_id = nil
        game_teams_ids = if is_an_by_slot
          team_id = bye_slot_teams.first
          next_bracket_info = playoff.brackets.where(current_bracket: next_bracket).first
          next_bracket_info.teams_ids[next_bracket_info.previous_brackets.count] = team_id
          next_bracket_info.save!

          winner_team = Playoffs::Team.where(id: team_id).first

          winner_team.current_bracket_id = next_bracket_info.id.to_s
          winner_team.save(validate: false)

          winner_id = team_id
          bye_slot_teams -= [team_id]
          [team_id, nil]
        else
          pair = paired_teams.sample(2)
          paired_teams -= pair
          pair
        end

        create_bracket(idx, 1, next_bracket, next_bracket_id, game_teams_ids, winner_id)

        next_bracket_info = playoff.brackets.where(current_bracket: next_bracket).first
        next_bracket_info.previous_brackets << idx
        next_bracket_info.save!
      end
    end

    def create_bracket current_bracket, round, next_bracket = nil, next_bracket_id = nil, teams_ids = [nil, nil], winner_id = nil
      bracket = playoff.brackets.create({
        current_bracket: current_bracket,
        round: round,
        next_bracket: next_bracket,
        next_bracket_id: next_bracket_id,
        previous_brackets: [],
        teams_ids: teams_ids,
        winner_team_id: winner_id
      })

      if !winner_id
        teams_ids.each do |team_id|
          next unless team_id
          team = Playoffs::Team.find(team_id)
          team.current_bracket_id = bracket.id
          team.save
        end
      end

      bracket
    end

    def get_previous_bracket
      # @previous_round_bracket_info.delete_at(rand(previous_round_bracket_info.length))
      @previous_round_bracket_info.shift
    end

    def previous_info(bracket)
      # current bracket comes from the previous 2 brackets, and previous as info of next
      # because of this that 2 brackets will have the same info of next bracket
      [[bracket.current_bracket, bracket.id.to_s]] * 2
    end
  end
end
