module Denormalization
  class DenormalizeTicketInfoToTicketBundles < ApplicationService
    def call(ticket, ticket_bundle = nil)
      if ticket_bundle
        if ticket_bundle.new_record?
          ticket_bundle.assign_attributes(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address,
            ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address
          )
        else
          ticket_bundle.update(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address,
            ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address
          )
        end
      else
        ticket.ticket_bundles.update_all(
          ticket_factory_contract_address: ticket.ticket_factory_contract_address,
          ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address
        )
      end
    end
  end
end
