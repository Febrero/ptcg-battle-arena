class Article
  MAX_ACTIVE_ARTICLES = 5
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include ::Uid

  field :title, type: String
  field :subtitle, type: String
  field :cover_image_url, type: String
  field :url, type: String
  field :description, type: String
  field :active, type: Boolean
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :position_order, type: Integer, default: 1

  validates_presence_of :title, :subtitle, :cover_image_url, :description, :active
  validate :validate_start_date, if: -> { start_date.present? }
  validate :validate_end_date, if: -> { end_date.present? }
  validate :validate_max_active_articles, if: -> { active_changed? && active }

  index({active: 1}, {name: "active_index", background: true})
  index({start_date: 1}, {name: "start_date_index", background: true, sparse: true})
  index({end_date: 1}, {name: "end_date_index", background: true, sparse: true})
  index({position_order: 1}, {name: "position_order_index", background: true, sparse: true})

  private

  def validate_max_active_articles
    if Article.where(active: true).count >= MAX_ACTIVE_ARTICLES
      errors.add(:active, "There are already #{MAX_ACTIVE_ARTICLES} active articles")
    end
  end

  def validate_start_date
    if end_date.present? && start_date >= end_date
      errors.add(:start_date, "Must be before the end date")
    end
  end

  def validate_end_date
    if start_date.present? && end_date <= start_date
      errors.add(:end_date, "Must be after the start date")
    end
  end
end
