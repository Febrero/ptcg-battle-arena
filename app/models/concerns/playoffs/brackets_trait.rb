module Playoffs
  module BracketsTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def format_brackets(teams_by_id = nil)
      return {} if brackets.count == 0
      @teams_by_id = teams_by_id
      bracket_info(brackets.order(current_bracket: :desc).all.to_a)
    end

    def generate_brackets
      Playoffs::GenerateBrackets.call(uid)
    end

    def flat_brackets
      return [] if brackets.count == 0
      @teams_by_id = teams.index_by { |team| team.id.to_s }
      all_brackets = brackets.order(current_bracket: :asc).all.to_a
      all_brackets.map do |bracket|
        bracket = bracket.attributes.except("_id").merge({"id" => bracket.id.to_s, "teams_info" => bracket.teams_info(false, @teams_by_id), "winner_team_name" => @teams_by_id[bracket.winner_team_id]&.name})
        bracket["previous_brackets"] = bracket["previous_brackets"].reverse
        bracket
      end
    end

    def bracket_info brackets, bracket = brackets.shift
      breaket_info = bracket.attributes.except("_id").merge({"id" => bracket.id.to_s, "teams_info" => bracket.teams_info(false, @teams_by_id)})

      return breaket_info if bracket.round == 1

      bracket_h = breaket_info.merge({"child_brackets" => []})

      brackets.select { |b| b.next_bracket == bracket.current_bracket }.each do |child_bracket|
        bracket_h["child_brackets"] << bracket_info(brackets, brackets.delete(child_bracket))
      end

      bracket_h
      # p bracket_h
    end
  end
end
