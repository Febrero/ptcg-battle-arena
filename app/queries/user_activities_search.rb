class UserActivitiesSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "gte_created_at", type: :gte},
    {field: "lte_created_at", type: :lte},
    {field: "gte_event_date", type: :gte},
    {field: "lte_event_date", type: :lte},
    {field: "source_type", type: :array},
    {field: "season_uid", type: :value},
    {field: "rewards_status", type: :value}
  ]
  ALLOWED_ORDERS = [:created_at, :event_date]

  def initialize(params, scope = UserActivity)
    super(params, scope)
  end
end
