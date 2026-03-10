module UserActivities
  module EventHandlers
    module Rewards
      class Base < UserActivities::EventHandler
        attr_accessor :event

        def reward_type
          event["reward_type"]&.downcase
        end

        def reward_subtype
          event["reward_subtype"]&.downcase
        end

        def offer_detail
          event["offer_detail"]
        end

        def source
          "rewards"
        end

        def source_key
          event["key"]
        end

        def value
          event["final_value"]
        end

        def status
          case event["state"]
          when "available", "admin_pending", "approved" then "pending"
          when "canceled" then "canceled"
          when "delivered" then "completed"
          end
        end

        def delivered_at
          event["delivered_at"]
        end

        def reward
          @reward ||= user_activity.rewards.where(source_key: event["key"]).first
        end

        def user_activity
          @user_activity ||= UserActivity.where(user_activity_query).first
        end

        def user_activity_query
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end
