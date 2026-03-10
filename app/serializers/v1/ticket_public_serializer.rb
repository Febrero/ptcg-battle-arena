module V1
  class TicketPublicSerializer < ActiveModel::Serializer
    def attributes(*args)
      hash = super
      hash[:uid] = uid
      hash[:name] = object.name
      hash[:description] = object.description
      hash[:erc20] = object.token["address"]
      hash[:image] = image
      hash[:price] = price
      hash[:expire_date] = expire_date
      hash[:attributes] = attributes_list
      hash
    end

    def uid
      object.bc_ticket_id
    end

    def image
      object.image_url
    end

    def price
      object.base_price
    end

    def expire_date
      object.expiration_date.to_i
    end

    def attributes_list
      [
        {
          trait_type: "Name",
          value: object.name
        }
      ]
    end
  end
end
