module UserActivities
  module EventHandlers
    module Prizes
      class Survival < Base
        def value
          game_mode.stages.find_by(level: event["survival_levels_completed"]).prize_amount
        end

        def entry
          @entry ||= begin
            survival_player = SurvivalPlayer.in("entries.games_ids": event["game_id"], wallet_addr: event["wallet_addr"]).first
            survival_player.entries.in(games_ids: event["game_id"]).first
          end
        end

        def user_activity_query
          {source_type: "Survival", "event_info.entry_id": entry.id.to_s}
        end
      end
    end
  end
end
