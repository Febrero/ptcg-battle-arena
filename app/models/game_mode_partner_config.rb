class GameModePartnerConfig
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :uid, type: Integer
  field :name, type: String
  field :custom_maps_settings, type: Hash
  has_many :game_modes, inverse_of: :game_mode, foreign_key: :game_mode_id, primary_key: :uid, class_name: "GameMode"

  index({uid: 1}, {name: "uid_index", background: true})
end
