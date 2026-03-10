class TicketBundle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :image_url, type: String
  field :tickets_quantity, type: Integer
  field :old_price, type: Float
  field :discount, type: Float
  field :final_price, type: Float
  field :name, type: String
  field :slug, type: String
  field :order, type: Integer
  field :sale_expiration_date, type: Time
  field :ticket_factory_contract_address, type: String
  field :ticket_locker_and_distribution_contract_address, type: String

  belongs_to :ticket
end
