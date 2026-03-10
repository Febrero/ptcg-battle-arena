class SplashScreensSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "name", type: :value},
    {field: "active", type: :value}
  ]
  ALLOWED_ORDERS = [:updated_at, :created_at]

  def initialize(params)
    super(params, SplashScreen)
  end
end
