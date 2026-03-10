class PlayoffsTeamSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "playoff_id", type: :int_array},
    {field: "wallet_addr", type: :array},
    {field: "still_in_playoff", type: :boolean}
  ]

  ALLOWED_ORDERS = [:created_at, :ended_at]
  DEFAULT_ORDER = {last_round: :desc, name: :asc}

  ##
  # if realfevr-libs-gem is imported should be
  # DEFAULT_ORDER = {last_round: :desc, name: :asc}

  def initialize(params)
    super(params, Playoffs::Team)
  end

  def apply_pagination
    default_per_page = self.class::DEFAULT_PER_PAGE
    max_per_page = self.class::MAX_PER_PAGE
    if @params.dig(:filter, :playoff_id)
      default_per_page = Playoff::TOTAL_TEAMS_FORMAT.max
      max_per_page = default_per_page
    end

    @pagination = BaseSearch::Pagination.new(
      @scope,
      @params,
      {
        default_page: self.class::DEFAULT_PAGE,
        default_per_page: default_per_page,
        max_per_page: max_per_page
      }
    )
    @pagination.apply
  end
end

BaseSearch::Filter.class_eval {
  def filter_int_array(field, value)
    @scope = @scope.in("#{field}": value.to_s.include?(",") ? value.split(",").map(&:to_i) : value.to_i)
  end
}
