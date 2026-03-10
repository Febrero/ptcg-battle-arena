class PlayoffsSearch < BaseSearch::Search
  attr_reader :collection, :params
  ALLOWED_FILTERS = [
    {field: "uid", type: :array},
    {field: "has_custom_prize", type: :boolean},
    {field: "erc20_name", type: :value},
    {field: "state", type: :value},
    {field: "active", type: :array},
    {field: "admin_only", type: :array}
  ]
  ALLOWED_ORDERS = [:uid, :open_date]
  DEFAULT_ORDER = {open_date: :asc}

  def initialize(params)
    @collection = Playoff
    @params = params
    params[:filter] ||= {}
    default_filter
    xp_level_filter
    super(params, collection)
  end

  def apply_orders
    @orders = BaseSearch::Order.new(
      @scope,
      @params,
      {
        allowed_orders: self.class::ALLOWED_ORDERS,
        default_order: (params[:sort]&.include?("open_date") ? [] : self.class::DEFAULT_ORDER)
      }
    )
    @orders.apply
  end

  private

  def default_filter
    if params.dig(:filter, :active).nil?
      params[:filter]["active"] = true
    end

    if params.dig(:filter, :admin_only).nil?
      params[:filter]["admin_only"] = false
    end

    if params.dig(:filter, :admin).nil?
      params[:filter]["admin"] = false
    end
  end

  def xp_level_filter
    return if !(xp_level = params.dig(:filter, :xp_level))

    @collection = collection.any_of(
      {:min_xp_level.lte => xp_level, :max_xp_level.gte => xp_level},
      {min_xp_level: nil},
      {:min_xp_level.exists => false}
    )
    params[:filter].delete(:xp_level)
  end
end
