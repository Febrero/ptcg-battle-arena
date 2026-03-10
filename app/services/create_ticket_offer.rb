class CreateTicketOffer < ApplicationService
  def call(params)
    params.deep_symbolize_keys!
    ticket = Ticket.in(tickets_query(params)).first

    TicketOffer.create!(
      quantity: params[:quantity],
      wallet_addr: params[:wallet_addr],
      reward_key: params[:reward_key],
      source: params[:source],
      created_by: params[:created_by],
      ticket: ticket
    )
  end

  private

  def tickets_query(params)
    {
      ticket_factory_contract_address: params[:ticket_factory_contract_address],
      bc_ticket_id: params[:bc_ticket_id]
    }.compact_blank
  end
end
