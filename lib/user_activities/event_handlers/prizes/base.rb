module UserActivities
  module EventHandlers
    module Prizes
      class Base < UserActivities::EventHandler
        def handle
          return if event["prize_awarded"] == false

          return if event["game_mode_id"].nil?

          return if Game.where(game_id: event_game_id).empty?

          if UserActivity.where("rewards.source_key": source_key).exists?
            handle_update_event
          else
            handle_create_event
          end
        end

        def status
          case event["state"]
          when "available", "admin_pending" then "pending"
          when "canceled" then "canceled"
          when "processed" then "completed"
          end
        end

        def reward_type
          event["erc20_name"]&.downcase
        end

        def reward_subtype
          nil
        end

        def offer_detail
          nil
        end

        def source
          "prizes"
        end

        def source_key
          event["id"]
        end

        def delivered_at
          event["delivered_at"]
        end

        def event_game_id
          event["game_id"]
        end

        def game_mode
          GameMode.find_by(uid: event["game_mode_id"])
        end

        def user_activity
          @user_activity ||= UserActivity.where(user_activity_query).first
        end

        def reward
          @reward ||= user_activity.rewards.where(source_key: event["id"]).first
        end

        def user_activity_query
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end
