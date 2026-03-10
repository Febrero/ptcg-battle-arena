class SeasonsSearch < BaseSearch::Search
  MAX_PER_PAGE = 100

  ALLOWED_FILTERS = [
    {field: "active", type: :boolean}
  ]
  ALLOWED_ORDERS = [:start_date]
  DEFAULT_ORDER = {start_date: :desc}

  def initialize(params)
    super(params, Season)
  end
end
