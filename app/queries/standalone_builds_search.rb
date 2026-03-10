class StandaloneBuildsSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "visibility", type: :value}
  ]
  ALLOWED_ORDERS = [:created_at]

  def initialize(params)
    super(params, StandaloneBuild)
  end
end
