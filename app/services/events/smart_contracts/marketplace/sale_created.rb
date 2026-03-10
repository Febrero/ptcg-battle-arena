module Events
  module SmartContracts
    module Marketplace
      class SaleCreated < ApplicationService
        def call(event)
          RemoveNftFromDecks.call(event["nft_id"])
        end
      end
    end
  end
end
