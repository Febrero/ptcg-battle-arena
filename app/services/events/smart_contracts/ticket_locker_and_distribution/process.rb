module Events
  module SmartContracts
    module TicketLockerAndDistribution
      class Process < ApplicationService
        def call(event)
          case event["event_name"]
          when "Locked"
            Events::SmartContracts::TicketLockerAndDistribution::Locked.call(event)
          else
            Rails.logger.info "Event handler not implemented"
          end
        end
      end
    end
  end
end
