class Season
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :uid, type: Integer
  field :name, type: String

  field :start_date, type: DateTime
  field :end_date, type: DateTime

  field :active, type: Boolean

  validates :uid, uniqueness: true

  validates :name, presence: true
  validates :start_date, presence: true

  index({uid: 1}, {unique: true, name: "uid_index", background: true})

  scope :currently_active, -> { where(active: true).order(start_date: :desc) }

  default_scope -> { gte(uid: 1) }
end
