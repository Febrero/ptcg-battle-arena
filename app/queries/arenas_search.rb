class ArenasSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "active", type: :value},
    {field: "admin_only", type: :array},
    {field: "admin", type: :array}
    # { field: 'end_date',   type: :lte },
    # { field: 'start_date', type: :gte }
  ]
  DEFAULT_ORDER = {uid: :asc}

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
    super(params, Arena)
  end
end
