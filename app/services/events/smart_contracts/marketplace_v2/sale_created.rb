module Events
  module SmartContracts
    module MarketplaceV2
      class SaleCreated < ApplicationService
        def call(event)
          RemoveNftFromDecks.call(event["nft_id"])
        end
      end
    end
  end
end
