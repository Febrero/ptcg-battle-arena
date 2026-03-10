module Callbacks
  module TopMoments
    module NftStatsCallbacks
      def before_validation(event)
        event.wallet_addr_downcase = event.wallet_addr.downcase
        event.uid = event.generate_uid
      end
    end
  end
end
