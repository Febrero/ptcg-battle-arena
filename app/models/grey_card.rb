class GreyCard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uid, type: Integer
  field :rarity, type: String
  field :player_name, type: String
  field :drop, type: String
  field :drop_slug, type: String
  field :position, type: String
  field :defense, type: Integer
  field :attack, type: Integer
  field :stamina, type: Integer
  field :ball_stopper, type: Boolean
  field :super_sub, type: Boolean
  field :man_mark, type: Integer
  field :enforcer, type: Boolean
  field :power, type: Integer
  field :inspire, type: String
  field :captain, type: String
  field :long_passer, type: Boolean
  field :box_to_box, type: Boolean
  field :dribbler, type: Boolean

  has_many :wallet_grey_cards, foreign_key: :grey_card_id, primary_key: "uid"

  index({uid: 1}, {name: "uid_index", background: true})
  index({rarity: 1}, {name: "rarity_index", background: true})
  index({position: 1}, {name: "position_index", background: true})
  index({defense: 1}, {name: "defense_index", background: true})
  index({attack: 1}, {name: "attack_index", background: true})
  index({stamina: 1}, {name: "stamina_index", background: true})
  index({ball_stopper: 1}, name: "ball_stopper_index", background: true)
  index({super_sub: 1}, name: "super_sub_index", background: true)
  index({man_mark: 1}, name: "man_mark_index", background: true)
  index({enforcer: 1}, name: "enforcer_index", background: true)
  index({updated_at: 1}, {name: "updated_at_index", background: true})
  index({inspire: 1}, name: "inspire_index", background: true)
  index({captain: 1}, name: "captain_index", background: true)
  index({long_passer: 1}, name: "long_passer_index", background: true)
  index({box_to_box: 1}, name: "box_to_box_index", background: true)
  index({dribbler: 1}, name: "dribbler_index", background: true)
end
