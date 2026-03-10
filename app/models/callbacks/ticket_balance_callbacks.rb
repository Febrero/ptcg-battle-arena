module Callbacks
  module TicketBalanceCallbacks
    def before_create(ticket_balance)
      denormalize_ticket_info_to_ticket_balance(ticket_balance)
    end

    private

    def denormalize_ticket_info_to_ticket_balance(ticket_balance)
      Denormalization::DenormalizeTicketInfoToTicketBalances.call(ticket_balance.ticket, ticket_balance)
    end
  end
end
