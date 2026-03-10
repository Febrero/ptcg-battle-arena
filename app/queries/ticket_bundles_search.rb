class TicketBundlesSearch
  MAX_PER_PAGE = 100

  def initialize(params, klass = TicketBundle)
    @params = params
    @klass = klass
    @scope = klass
  end

  # @return [Colection, Int, Int, Int]
  def search
    @scope = set_initial_scope
    [cached_results, page.to_i, per_page.to_i, cached_count]
  end

  protected

  # @abstract Override for implementing a custom initial scope
  #
  # @return [Mongoid::Criteria] The original criteria enhanced
  #
  # @example
  #   @scope.where(xpto: 123)
  #
  def set_initial_scope
    @scope
  end

  def per_page
    per_page = @params[:per_page] || 24
    (per_page.to_i <= MAX_PER_PAGE) ? per_page.to_i : MAX_PER_PAGE
  end

  def page
    @params[:page].to_i || 1
  end

  def cached_count
    @_count ||= @scope.count
  end

  def cached_results
    Rails.cache.fetch("TicketBundlesSearch::Page:#{page}::PerPage:#{per_page}", expires_in: 30.seconds) do
      @scope.paginate(page: page, limit: per_page).to_a
    end
  end
end
