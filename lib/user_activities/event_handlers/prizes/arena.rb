module UserActivities
  module EventHandlers
    module Prizes
      class Arena < Base
        def value
          game_mode.prize_pool_winner_share
        end

        def user_activity_query
          {source_type: "Arena", "event_info.game_id": event["game_id"], wallet_addr: event["wallet_addr"]}
        end
      end
    end
  end
end
