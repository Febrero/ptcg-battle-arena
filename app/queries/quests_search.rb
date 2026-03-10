class QuestsSearch < BaseSearch::Search
  MAX_PER_PAGE = 100

  ALLOWED_FILTERS = [
    {field: "active", type: :boolean}
  ]
  ALLOWED_ORDERS = [:created_at]
  DEFAULT_ORDER = {created_at: :desc}

  def initialize(params)
    super(params, GameType::Quest)
  end
end
