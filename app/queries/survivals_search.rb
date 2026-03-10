class SurvivalsSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "state", type: :value},
    {field: "active", type: :array},
    {field: "admin_only", type: :array},
    {field: "admin", type: :array}
    # { field: 'end_date',   type: :lte },
    # { field: 'start_date', type: :gte }
  ]
  ALLOWED_ORDERS = [:uid, :start_date]

  # @note This is the default order for the search, should changed if realfevr-libs gem goes to production
  # DEFAULT_ORDER = {end_date: :asc}
  DEFAULT_ORDER = {end_date: :asc}

  def initialize(params)
    params[:filter] ||= {}
    if !params.dig(:filter, :active)
      params[:filter]["active"] = true
    end

    if !params.dig(:filter, :admin)
      params[:filter]["admin"] = false
    end

    if !params.dig(:filter, :admin_only)
      params[:filter]["admin_only"] = false
    end

    super(params, Survival)
  end
end
