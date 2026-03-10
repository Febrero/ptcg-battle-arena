module Tickets
  class SpendTicketsPlayoff < Tickets::BaseSpendTickets
    def initialize(playoff_uid, ticket_id, wallet_addr, check_entry_charged = true, ticket_amount = nil)
      @playoff_uid = playoff_uid
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @ticket_id = ticket_id.to_i
      @wallet_addr = wallet_addr
      @check_entry_charged = check_entry_charged
      @ticket_amount = ticket_amount || playoff.ticket_amount_needed || 1
      @ticket_amount = @ticket_amount.to_i
    end

    def call
      charge
    end

    def charge
      return true if @ticket_id.zero? && @check_entry_charged && entry_already_charged?

      return false if !team_have_enough_tickets_deposited

      charge_entry
      true
    end

    def get_ticket_balance
      @ticket_balance ||= TicketBalance.where(
        bc_ticket_id: @ticket_id,
        wallet_addr: @wallet_addr,
        ticket_factory_contract_address: @playoff.ticket_factory_contract_address
      ).first
    end

    def team_have_enough_tickets_deposited
      get_ticket_balance

      @ticket_balance.deposited >= @ticket_amount
    end

    def charge_entry
      get_ticket_balance
      @ticket_balance.deposited -= @ticket_amount
      @ticket_balance.save

      set_entry_key
    end

    def revert_charge_entry
      return if @ticket_id.zero?
      get_ticket_balance
      @ticket_balance = @ticket_balance.reload
      @ticket_balance.deposited += @ticket_amount
      @ticket_balance.save

      del_entry_key
    end

    def redis_key
      "Playoff::#{@playoff_uid}::#{@wallet_addr}"
    end

    def self.response_error_message(compatible_ticket_ids)
      {
        error: {
          code: "insufficient_tickets",
          message: "You don't have enough tickets to perform this action.",
          details: {
            compatible_ticket_ids: compatible_ticket_ids
          },
          suggested_action: "Please purchase more tickets to proceed."
        }
      }
    end
  end
end
