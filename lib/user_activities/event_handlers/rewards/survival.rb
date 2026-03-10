module UserActivities
  module EventHandlers
    module Rewards
      class Survival < Base
        def user_activity_query
          survival_player = SurvivalPlayer.in("entries.games_ids": event["game_id"], wallet_addr: event["wallet_addr"]).first
          entry = survival_player.entries.in(games_ids: event["game_id"]).first
          {source_type: "Survival", "event_info.entry_id": entry.id.to_s}
        end
      end
    end
  end
end
