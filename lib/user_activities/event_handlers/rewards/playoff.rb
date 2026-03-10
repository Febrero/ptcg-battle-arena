module UserActivities
  module EventHandlers
    module Rewards
      class Playoff < Base
        def user_activity_query
          playoff_id = Game.find_by(game_id: event["game_id"]).game_mode_id
          playoff = ::Playoff.find_by(uid: playoff_id)
          team = playoff.teams.find_by(wallet_addr_downcased: event["wallet_addr"].downcase)

          {source_type: "Playoff", "event_info.team_id": team.id.to_s}
        end
      end
    end
  end
end
