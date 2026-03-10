class TicketBalance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :wallet_addr, type: String
  field :balance, default: 0, type: Integer
  field :deposited, default: 0, type: Integer
  field :bc_ticket_id, type: Integer
  field :ticket_factory_contract_address, type: String
  field :ticket_locker_and_distribution_contract_address, type: String

  validates :wallet_addr, presence: true
  validates :balance, presence: true
  validates :deposited, presence: true
  validates :bc_ticket_id, uniqueness: {scope: [:wallet_addr, :ticket_factory_contract_address]}

  scope :to_offer, -> { where(wallet_addr: Rails.application.config.ticket_offer_wallet_addr) }

  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
  index({bc_ticket_id: 1}, {name: "bc_ticket_id_index", background: true})
  index(
    {wallet_addr: 1, bc_ticket_id: 1, ticket_factory_contract_address: 1},
    {unique: true, name: "wallet_addr_bc_ticket_id_ticket_factory_contract_address_index", background: true}
  )

  belongs_to :ticket
end
