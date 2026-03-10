module Events
  module SmartContracts
    module MarketplaceV3
      class Process < ApplicationService
        def call(event)
          if Events::SmartContracts::ValidateTransaction.call(event)
            case event["event_name"]
            when "SaleCreated"
              Events::SmartContracts::MarketplaceV3::SaleCreated.call(event)
            else
              Rails.logger.info "Event handler not implemented"
            end
          end
        end
      end
    end
  end
end
