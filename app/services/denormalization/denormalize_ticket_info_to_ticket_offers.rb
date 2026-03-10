module Denormalization
  class DenormalizeTicketInfoToTicketOffers < ApplicationService
    def call(ticket, ticket_offer = nil)
      if ticket_offer
        if ticket_offer.new_record?
          ticket_offer.assign_attributes(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address
          )
        else
          ticket_offer.update(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address
          )
        end
      else
        ticket.ticket_offers.update_all(
          ticket_factory_contract_address: ticket.ticket_factory_contract_address
        )
      end
    end
  end
end
