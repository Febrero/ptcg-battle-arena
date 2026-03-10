class PrizeConfigsSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "name", type: :array},
    {field: "active", type: :boolean}
  ]
  DEFAULT_ORDER = {uid: :asc}

  def initialize(params)
    super(params, Playoffs::PrizeConfig)
  end
end
