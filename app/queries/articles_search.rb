class ArticlesSearch < BaseSearch::Search
  attr_reader :params

  ALLOWED_FILTERS = [
    {field: "active", type: :value},
    {field: "start_date", type: :value},
    {field: "gte_start_date", type: :gte},
    {field: "end_date", type: :value},
    {field: "lte_end_date", type: :lte}
  ]
  ALLOWED_ORDERS = [:start_date, :end_date, :position_order]
  DEFAULT_ORDER = {position_order: :asc}

  def initialize(params, scope = nil)
    @params = params
    params[:filter] ||= {}
    super(params, scope || default_scope)
  end

  private

  def default_scope
    Article.where(
      active: true
    ).and("$or" => [
      {
        start_date: nil,
        end_date: nil
      },
      {
        :start_date.lte => DateTime.now,
        :end_date => nil
      },
      {
        :start_date => nil,
        :end_date.gte => DateTime.now
      },
      {
        :start_date.lte => DateTime.now,
        :end_date.gte => DateTime.now
      }
    ])
  end
end
