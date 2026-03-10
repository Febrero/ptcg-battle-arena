module UserActivities
  module EventHandlers
    module Rewards
      class Arena < Base
        def handle
          return unless GameMode.where(uid: event["arena"]).present?

          if UserActivity.where("rewards.source_key": source_key).exists?
            handle_update_event
          else
            handle_create_event
          end
        end

        def user_activity_query
          {source_type: "Arena", "event_info.game_id": event["game_id"], wallet_addr: event["wallet_addr"]}
        end
      end
    end
  end
end
