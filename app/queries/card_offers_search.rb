class CardOffersSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "wallet_addr", type: :value},
    {field: "quantity", type: :value},
    {field: "delivered", type: :value},
    {field: "card_type", type: :value},
    {field: "reward_key", type: :value},
    {field: "source", type: :value}
  ]
  ALLOWED_ORDERS = [:updated_at, :created_at]

  def initialize(params)
    super(params, CardOffer)
  end
end
