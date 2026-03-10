# lib/base_search.rb
#
# Recreated from the removed realfevr_libs gem.
# Provides BaseSearch::Search, BaseSearch::Filter, BaseSearch::Order, BaseSearch::Pagination
# for Mongoid-backed search/filter/sort/paginate queries used across all app/queries/*.rb files.

module BaseSearch
  # ─────────────────────────────────────────────────────────────────────────────
  # Filter — applies ALLOWED_FILTERS to a Mongoid scope
  # ─────────────────────────────────────────────────────────────────────────────
  class Filter
    attr_reader :scope

    def initialize(scope, params, allowed_filters)
      @scope           = scope
      @params          = params
      @allowed_filters = Array(allowed_filters)
    end

    def apply
      filter_params = @params[:filter] || {}

      @allowed_filters.each do |filter_def|
        field = filter_def[:field].to_s
        type  = filter_def[:type]

        next unless filter_params.key?(field) || filter_params.key?(field.to_sym)

        value = filter_params[field] || filter_params[field.to_sym]
        next if value.nil? || value.to_s.strip.empty?

        filter_method = :"filter_#{type}"
        if respond_to?(filter_method, true)
          send(filter_method, field, value)
        else
          # Fallback to simple equality
          @scope = @scope.where(field.to_sym => value)
        end
      end

      @scope
    end

    private

    # :value — exact match
    def filter_value(field, value)
      @scope = @scope.where(field.to_sym => value)
    end

    # :value_case_insensitive — case-insensitive regex match
    def filter_value_case_insensitive(field, value)
      @scope = @scope.where(field.to_sym => /\A#{Regexp.escape(value.to_s)}\z/i)
    end

    # :array — field $in array (comma-separated string or actual array)
    def filter_array(field, value)
      values = value.is_a?(Array) ? value : value.to_s.split(",").map(&:strip)
      @scope = @scope.in(field.to_sym => values)
    end

    # :array_case_insensitive — $in with case-insensitive regex
    def filter_array_case_insensitive(field, value)
      values = value.is_a?(Array) ? value : value.to_s.split(",").map(&:strip)
      regexes = values.map { |v| /\A#{Regexp.escape(v)}\z/i }
      @scope = @scope.any_in(field.to_sym => regexes)
    end

    # :filter_array_case_insensitive — alias for array_case_insensitive
    def filter_filter_array_case_insensitive(field, value)
      filter_array_case_insensitive(field, value)
    end

    # :boolean — cast to true/false
    def filter_boolean(field, value)
      bool = ActiveModel::Type::Boolean.new.cast(value)
      @scope = @scope.where(field.to_sym => bool)
    end

    # :lte — less than or equal
    def filter_lte(field, value)
      @scope = @scope.where(:"#{field}".lte => value)
    end

    # :gte — greater than or equal
    def filter_gte(field, value)
      @scope = @scope.where(:"#{field}".gte => value)
    end

    # :has_truthy_value — field is present/non-empty
    def filter_has_truthy_value(field, value)
      bool = ActiveModel::Type::Boolean.new.cast(value)
      if bool
        @scope = @scope.where(:"#{field}".nin => [nil, "", 0, false])
      else
        @scope = @scope.any_of(
          {field.to_sym => nil},
          {field.to_sym => ""},
          {field.to_sym => 0},
          {field.to_sym => false}
        )
      end
    end

    # :int_array — $in with integer coercion
    def filter_int_array(field, value)
      values = value.to_s.include?(",") ? value.to_s.split(",").map(&:to_i) : [value.to_i]
      @scope = @scope.in(field.to_sym => values)
    end

    # :no_abilities — special composite filter (overridable via class_eval)
    def filter_no_abilities(_field, _value)
      # Default no-op; subclasses/callers extend via BaseSearch::Filter.class_eval
      @scope
    end

    # :ticket_not_expired — boolean active + expiration check (overridable)
    def filter_ticket_not_expired(field, value)
      bool = ActiveModel::Type::Boolean.new.cast(value)
      @scope = @scope.where(:"#{field}" => bool, :expiration_date.gte => Time.now)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Order — applies sorting to a Mongoid scope
  # ─────────────────────────────────────────────────────────────────────────────
  class Order
    attr_reader :scope

    DEFAULT_DIRECTION = :asc

    def initialize(scope, params, options = {})
      @scope          = scope
      @params         = params
      @allowed_orders = Array(options[:allowed_orders]).map(&:to_sym)
      @default_order  = options[:default_order] || {}
    end

    def apply
      sort_param = @params[:sort].presence

      if sort_param
        parsed = parse_sort_param(sort_param)
        if parsed.any?
          parsed.each do |field, direction|
            @scope = @scope.order_by([[field, direction]])
          end
          return @scope
        end
      end

      # Fall back to default order
      if @default_order.any?
        @default_order.each do |field, direction|
          @scope = @scope.order_by([[field.to_sym, direction]])
        end
      end

      @scope
    end

    private

    def parse_sort_param(sort_param)
      result = {}
      parts  = sort_param.to_s.split(",").map(&:strip)

      parts.each do |part|
        if part.start_with?("-")
          field = part[1..].to_sym
          dir   = :desc
        else
          field = part.to_sym
          dir   = :asc
        end

        next unless @allowed_orders.empty? || @allowed_orders.include?(field)

        result[field] = dir
      end

      result
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Pagination — paginates a Mongoid scope, returns [results, page, per_page, total]
  # ─────────────────────────────────────────────────────────────────────────────
  class Pagination
    DEFAULT_PAGE     = 1
    DEFAULT_PER_PAGE = 24
    MAX_PER_PAGE     = 100

    attr_reader :scope, :page, :per_page, :total

    def initialize(scope, params, options = {})
      @scope           = scope
      @params          = params
      @default_page    = (options[:default_page] || DEFAULT_PAGE).to_i
      @default_per_page = (options[:default_per_page] || DEFAULT_PER_PAGE).to_i
      @max_per_page    = (options[:max_per_page] || MAX_PER_PAGE).to_i
    end

    def apply
      @page     = [@params[:page].to_i, 1].max
      @per_page = resolve_per_page

      @total  = @scope.count
      @scope  = @scope.skip((@page - 1) * @per_page).limit(@per_page)

      @scope
    end

    private

    def resolve_per_page
      requested = @params[:per_page].to_i
      return @default_per_page if requested <= 0
      [requested, @max_per_page].min
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Search — main orchestrator used by all app/queries/*_search.rb classes
  # ─────────────────────────────────────────────────────────────────────────────
  class Search
    DEFAULT_PAGE     = 1
    DEFAULT_PER_PAGE = 24
    MAX_PER_PAGE     = 100

    def initialize(params, model_class)
      @params      = params.is_a?(ActionController::Parameters) ? params.to_unsafe_h.with_indifferent_access : params.with_indifferent_access
      @model_class = model_class
      @scope       = model_class
    end

    # @return [Array(Mongoid::Criteria, Integer, Integer, Integer)]
    #   [collection, page, per_page, total]
    def search
      @scope = apply_filters
      @scope = apply_orders
      @scope = apply_pagination

      [@scope, @pagination.page, @pagination.per_page, @pagination.total]
    end

    protected

    def apply_filters
      allowed = self.class.const_defined?(:ALLOWED_FILTERS) ? self.class::ALLOWED_FILTERS : []
      filter  = BaseSearch::Filter.new(@scope, @params, allowed)
      filter.apply
    end

    def apply_orders
      allowed  = self.class.const_defined?(:ALLOWED_ORDERS) ? self.class::ALLOWED_ORDERS : []
      default  = self.class.const_defined?(:DEFAULT_ORDER)  ? self.class::DEFAULT_ORDER  : {}
      @orders  = BaseSearch::Order.new(@scope, @params, allowed_orders: allowed, default_order: default)
      @orders.apply
    end

    def apply_pagination
      default_page     = self.class.const_defined?(:DEFAULT_PAGE)     ? self.class::DEFAULT_PAGE     : DEFAULT_PAGE
      default_per_page = self.class.const_defined?(:DEFAULT_PER_PAGE) ? self.class::DEFAULT_PER_PAGE : DEFAULT_PER_PAGE
      max_per_page     = self.class.const_defined?(:MAX_PER_PAGE)     ? self.class::MAX_PER_PAGE     : MAX_PER_PAGE

      @pagination = BaseSearch::Pagination.new(
        @scope,
        @params,
        default_page: default_page,
        default_per_page: default_per_page,
        max_per_page: max_per_page
      )
      @pagination.apply
    end
  end
end
