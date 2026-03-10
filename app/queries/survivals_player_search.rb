class SurvivalsPlayerSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "survival_id", type: :int_array},
    {field: "wallet_addr", type: :array}
  ]
  ALLOWED_ORDERS = []

  def initialize(params)
    super(params, SurvivalPlayer)
  end
end

BaseSearch::Filter.class_eval {
  def filter_int_array(field, value)
    @scope = @scope.in("#{field}": value.to_s.include?(",") ? value.split(",").map(&:to_i) : value.to_i)
  end
}
