module Denormalization
  class DenormalizeTicketInfoToTicketBalances < ApplicationService
    def call(ticket, ticket_balance = nil)
      if ticket_balance
        if ticket_balance.new_record?
          ticket_balance.assign_attributes(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address,
            ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address,
            bc_ticket_id: ticket.bc_ticket_id
          )
        else
          ticket_balance.update(
            ticket_factory_contract_address: ticket.ticket_factory_contract_address,
            ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address,
            bc_ticket_id: ticket.bc_ticket_id
          )
        end
      else
        ticket.ticket_balances.update_all(
          ticket_factory_contract_address: ticket.ticket_factory_contract_address,
          ticket_locker_and_distribution_contract_address: ticket.ticket_locker_and_distribution_contract_address,
          bc_ticket_id: ticket.bc_ticket_id
        )
      end
    end
  end
end
