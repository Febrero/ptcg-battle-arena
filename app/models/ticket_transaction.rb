class TicketTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :bc_ticket_id, type: Integer
  field :ticket_factory_contract_address, type: String
  field :amount, type: Integer

  validates :bc_ticket_id, :ticket_factory_contract_address, :amount, presence: true

  index({bc_ticket_id: 1}, {name: "bc_ticket_id_index", background: true})
  index({ticket_factory_contract_address: 1}, {name: "ticket_factory_contract_address_index", background: true})
  index({amount: 1}, {name: "amount_index", background: true})
end
