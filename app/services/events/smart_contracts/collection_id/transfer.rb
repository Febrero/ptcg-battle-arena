module Events
  module SmartContracts
    module CollectionId
      class Transfer < ApplicationService
        def call(event)
          return if BlockchainTransactionsUtils.is_marketplace_transaction?(event["from"], event["to"])
          return if BlockchainTransactionsUtils.is_mint_transaction?(event["from"])
          return if BlockchainTransactionsUtils.is_bridge_transaction?(event["from"], event["to"])

          nft = Nft.find(event["token_id"])
          video = begin
            FetchVideo.call(nft.video_id)
          rescue
            nil
          end

          if video
            RemoveNftFromDecks.call(event["token_id"])
          end
        end
      end
    end
  end
end
