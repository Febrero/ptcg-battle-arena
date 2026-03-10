class SplashScreen
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :name, type: String
  field :image_url, type: String
  field :active, type: Boolean

  validates :image_url, presence: true

  scope :active, -> { where(active: true) }

  index({name: 1}, {name: "name_index", background: true})
  index({active: 1}, {name: "active_index", background: true})
end
