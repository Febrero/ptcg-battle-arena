class TicketOffer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :quantity, type: Integer
  field :wallet_addr, type: String
  field :ticket_factory_contract_address, type: String
  field :offered, type: Boolean, default: false
  field :tx_hash, type: String
  field :reward_key, type: String
  field :source, type: String
  field :delivered_at, type: Time
  field :created_by, type: Integer

  belongs_to :ticket

  validates :wallet_addr, :quantity, presence: true
end
