class QuestStreaksSearch < BaseSearch::Search
  MAX_PER_PAGE = 100
  ALLOWED_FILTERS = [{field: "profile_id", type: :value}]
  ALLOWED_ORDERS = [:created_at]

  def initialize(params, scope = GameType::QuestStreak)
    super(params, scope)
  end
end
