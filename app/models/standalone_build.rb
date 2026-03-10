class StandaloneBuild
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :version, type: String
  field :exe_download_url, type: String
  field :dmg_download_url, type: String
  field :force_update, type: Boolean, default: false
  field :notes, type: String
  field :change_log, type: String
  field :visibility, type: String

  validates :version, presence: true, uniqueness: true
  validates :exe_download_url, presence: true
  validates :dmg_download_url, presence: true

  index({version: 1}, {name: "version_index", unique: true, background: true})
end
