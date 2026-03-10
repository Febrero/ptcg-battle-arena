module Callbacks
  module UserActivities
    module RewardCallbacks
      def after_save(reward)
        reward.user_activity.update_rewards_status
      end
    end
  end
end
