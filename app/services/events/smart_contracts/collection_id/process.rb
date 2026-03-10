module Events
  module SmartContracts
    module CollectionId
      class Process < ApplicationService
        def call(event)
          if Events::SmartContracts::ValidateTransaction.call(event)
            case event["event_name"]
            when "Transfer"
              Events::SmartContracts::CollectionId::Transfer.call(event)
            else
              Rails.logger.info "Event handler not implemented"
            end
          end
        end
      end
    end
  end
end
