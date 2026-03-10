module Callbacks
  module Playoffs
    module PrizeConfigCallbacks
      def before_create(prize_config)
        prize_config.uid = (::Playoffs::PrizeConfig.max(:uid) || 0) + 1
      end
    end
  end
end
