class DecksSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "id", type: :value},
    {field: "wallet_addr", type: :value},
    {field: "stars", type: :value},
    {field: "name", type: :value}
  ]
  ALLOWED_ORDERS = [:updated_at, :created_at]

  def initialize(params)
    super(params, Deck)
  end
end
