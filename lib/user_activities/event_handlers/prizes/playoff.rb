module UserActivities
  module EventHandlers
    module Prizes
      class Playoff < Base
        def event_game_id
          event["game_id"].split("-")[0..-2].join("-")
        end

        def value
          game_mode.get_prize_by_rounds_completed_and_number_of_players_in_round(
            event["playoff_rounds_completed"],
            event["playoff_number_of_players_in_round"]
          )
        end

        def user_activity_query
          playoff = ::Playoff.find_by(uid: event["game_mode_id"])
          team = playoff.teams.find_by(wallet_addr_downcased: event["wallet_addr"].downcase)

          {source_type: "Playoff", "event_info.team_id": team.id.to_s}
        end
      end
    end
  end
end
