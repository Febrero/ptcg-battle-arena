class WalletGreyCardsSearch < BaseSearch::Search
  MAX_PER_PAGE = 100

  ALLOWED_FILTERS = [
    {field: "id", type: :value},
    {field: "wallet_addr", type: :value_case_insensitive},
    {field: "rarity", type: :value},
    {field: "position", type: :value},
    {field: "grey_card_id", type: :value},
    {field: "ball_stopper", type: :value},
    {field: "super_sub", type: :value},
    {field: "enforcer", type: :value},
    {field: "man_mark", type: :value},
    {field: "inspire", type: :has_truthy_value},
    {field: "captain", type: :has_truthy_value},
    {field: "long_passer", type: :value},
    {field: "box_to_box", type: :value},
    {field: "dribbler", type: :value},
    {field: "no_abilities", type: :no_abilities}
  ]
  ALLOWED_ORDERS = %i[defense attack stamina power]

  def initialize(params)
    super(params, WalletGreyCard)
  end
end

BaseSearch::Filter.class_eval {
  def filter_no_abilities(_field, value)
    @scope = @scope.where(
      ball_stopper: false,
      super_sub: false,
      inspire: "",
      captain: "",
      man_mark: 0,
      enforcer: false,
      box_to_box: false,
      dribbler: false,
      long_passer: false
    )
  end
}
