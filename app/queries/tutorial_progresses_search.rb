class TutorialProgressesSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "wallet_addr", type: :filter_array_case_insensitive},
    {field: "completed", type: :value},
    {field: "steps.name", type: :array}
  ]
  ALLOWED_ORDERS = [:created_at]

  def initialize(params)
    super(params, TutorialProgress)
  end
end
