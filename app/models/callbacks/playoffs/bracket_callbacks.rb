module Callbacks
  module Playoffs
    module BracketCallbacks
      def before_create(bracket)
        # Rails.logger.info "BEFORE CREATE BRACKET #{bracket.current_bracket}"
        # Rails.logger.info "****************************************************"
        # puts bracket
        # puts bracket&.teams_ids

        # if bracket&.teams_ids&.include? nil
        #   winner = bracket.teams_ids.detect { |t| t.present? }
        #   bracket.winner_team_id = winner
        #   next_bracket = bracket.playoff.brackets.where(current_bracket: bracket.next_bracket).first
        #   next_bracket.teams_ids ||= []
        #   next_bracket.teams_ids << winner
        #   next_bracket.save
        # end
        # bracket
      end
    end
  end
end
