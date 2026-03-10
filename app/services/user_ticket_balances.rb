class UserTicketBalances < ApplicationService
  def call(wallet_addr)
    @wallet_addr = wallet_addr
    Ticket.where(active: true).map do |ticket|
      ticket_balance(ticket) || default_ticket_balance(ticket)
    end
  end

  private

  def ticket_balance(ticket)
    TicketBalance.where(
      wallet_addr: @wallet_addr,
      bc_ticket_id: ticket.bc_ticket_id,
      ticket_factory_contract_address: ticket.ticket_factory_contract_address
    ).first
  end

  def default_ticket_balance(ticket)
    TicketBalance.new({
      wallet_addr: @wallet_addr,
      balance: 0,
      deposited: 0,
      bc_ticket_id: ticket.bc_ticket_id,
      ticket: ticket,
      ticket_factory_contract_address: ticket.ticket_factory_contract_address
    })
  end
end
