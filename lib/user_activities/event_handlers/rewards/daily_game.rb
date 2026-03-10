module UserActivities
  module EventHandlers
    module Rewards
      class DailyGame < Base
        private

        def user_activity_query
          {
            wallet_addr: event["wallet_addr"],
            source_type: "GameType::Quest",
            "event_info.day": event["event_detail"]["day_quest"],
            "event_info.quest_streak_id": event["event_detail"]["quest_streak_id"]
          }
        end
      end
    end
  end
end
