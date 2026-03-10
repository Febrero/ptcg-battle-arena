module V1
  class TicketSerializer < ActiveModel::Serializer
    attributes :id,
      :bc_ticket_id,
      :name,
      :base_price,
      :expiration_date,
      :sale_expiration_date,
      :start_date,
      :description,
      :erc20,
      :erc20_name,
      :available_quantities,
      :image_url,
      :entry_image_url,
      :fees,
      :discount,
      :tickets_num_discount,
      :active,
      :position,
      :zero_fees,
      :promo,
      :game_mode,
      :ticket_factory_contract_address,
      :ticket_locker_and_distribution_contract_address,
      :can_be_bought

    # has_many :ticket_bundles, include_nested_associations: true

    def id
      object.id.to_s
    end

    def erc20
      object.token["address"]
    end

    def can_be_bought
      return true if !object.zero_fees

      return true if object.is_unique_zero_fees # allow everyone to buy if there are you one ticket of contract register with zero fees

      object.zero_fees && @instance_options[:zero_fees]
    end
  end
end
