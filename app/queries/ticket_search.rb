class TicketSearch < BaseSearch::Search
  MAX_PER_PAGE = 100

  ALLOWED_FILTERS = [
    {field: "bc_ticket_id", type: :value},
    {field: "ticket_factory_contract_address", type: :value},
    {field: "id", type: :value},
    {field: "active", type: :ticket_not_expired},
    {field: "zero_fees", type: :boolean},
    {field: "game_mode", type: :value}
  ]
  ALLOWED_ORDERS = [:position]
  DEFAULT_ORDER = {position: :asc}

  def initialize(params)
    super(params, Ticket)
  end
end

BaseSearch::Filter.class_eval {
  def filter_ticket_not_expired(field, value)
    @scope = @scope.where(:"#{field}" => ActiveModel::Type::Boolean.new.cast(value), :expiration_date.gte => Time.now)
  end
}
