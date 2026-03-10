module Events
  module SmartContracts
    module TicketFactory
      class Process < ApplicationService
        def call(event)
          case event["event_name"]
          when "BuyTicket"
            Events::SmartContracts::TicketFactory::BuyTicket.call(event)
          when "TransferSingle"
            Events::SmartContracts::TicketFactory::TransferSingle.call(event)
          when "TransferBatch"
            Events::SmartContracts::TicketFactory::TransferBatch.call(event)
          else
            Rails.logger.info "Event handler not implemented"
          end
        end
      end
    end
  end
end
