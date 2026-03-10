class GamesSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "players_wallet_addresses", type: :array_case_insensitive},
    {field: "game_id", type: :value},
    {field: "match_type", type: :value},
    {field: "lte_game_start_time", type: :lte},
    {field: "gte_game_start_time", type: :gte}
  ]
  ALLOWED_ORDERS = [:created_at]

  def initialize(params)
    super(params, Game)
  end
end
