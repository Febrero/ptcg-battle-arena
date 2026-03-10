module Events
  module SmartContracts
    module Opener
      class Transfer < ApplicationService
        def call(event)
          return if BlockchainTransactionsUtils.is_marketplace_transaction?(event["from"], event["to"])
          return if BlockchainTransactionsUtils.is_mint_transaction?(event["from"])
          return if BlockchainTransactionsUtils.is_bridge_transaction?(event["from"], event["to"])

          nft = Nft.find(event["token_id"])
          video = FetchVideo.call(nft.video_id)
          if video
            RemoveNftFromDecks.call(event["token_id"])
          end
        end
      end
    end
  end
end
