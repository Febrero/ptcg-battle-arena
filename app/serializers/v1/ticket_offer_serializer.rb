module V1
  class TicketOfferSerializer < ActiveModel::Serializer
    attributes :ticket_id,
      :quantity,
      :wallet_addr,
      :ticket_factory_contract_address,
      :offered,
      :tx_hash,
      :reward_key,
      :source,
      :ticket_name,
      :created_at,
      :delivered_at,
      :created_by

    def ticket_id
      object.ticket.bc_ticket_id
    end

    def ticket_name
      object.ticket.name
    end
  end
end
