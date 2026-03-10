class TicketOffersSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "ticket_id", type: :value},
    {field: "quantity", type: :value},
    {field: "wallet_addr", type: :array_case_insensitive},
    {field: "ticket_factory_contract_address", type: :value},
    {field: "offered", type: :value},
    {field: "tx_hash", type: :value}
  ]
  ALLOWED_ORDERS = [:updated_at, :created_at]

  def initialize(params)
    super(params, TicketOffer)
  end
end
