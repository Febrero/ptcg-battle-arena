module V1
  class TicketBundleSerializer < ActiveModel::Serializer
    attributes :image_url,
      :tickets_quantity,
      :old_price,
      :discount,
      :final_price,
      :name,
      :slug,
      :order,
      :sale_expiration_date,
      :bc_ticket_id,
      :ticket_factory_contract_address,
      :ticket_locker_and_distribution_contract_address,
      :ticket_id

    def ticket_id
      object.ticket.id.to_s
    end

    def bc_ticket_id
      object.ticket.bc_ticket_id
    end
  end
end
