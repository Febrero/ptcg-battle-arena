module Callbacks
  module TicketCallbacks
    def after_update(ticket)
      if should_denormalize_contract_addresses?(ticket)
        Denormalization::DenormalizeTicketInfoToTicketOffers.call(ticket)
        Denormalization::DenormalizeTicketInfoToTicketBundles.call(ticket)
        Denormalization::DenormalizeTicketInfoToTicketBalances.call(ticket)
      end
    end

    private

    def should_denormalize_contract_addresses?(ticket)
      ticket.changes.key?("ticket_factory_contract_address") ||
        ticket.changes.key?("ticket_locker_and_distribution_contract_address") ||
        ticket.changes.key?("bc_ticket_id")
    end
  end
end
