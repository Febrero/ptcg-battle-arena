class RewardsConfig
  include Mongoid::Document
  include Mongoid::Timestamps

  ACHIEVEMENT_TYPES = {
    play: "play",
    win: "win",
    score_five: "score_5plus",
    clean_sheet: "clean_sheet",
    hattrick: "hattrick",
    underdog: "underdog"
  }

  field :achievement_type, type: String
  field :achievement_value, type: Integer
  field :desc, type: String

  index({achievement_type: 1}, {name: "achievement_type_index", background: true})
end

#
# RewardsConfig.create([
#   { achievement_type: "win",         achievement_value: 10, desc: "Game won"},
#   { achievement_type: "play",        achievement_value: 20, desc: "Game played"},
#   { achievement_type: "score_5plus", achievement_value: 5,  desc: "Scored more than 4 goals"},
#   { achievement_type: "clean_sheet", achievement_value: 5,  desc: "Kept a cleansheet"},
#   { achievement_type: "hattrick",    achievement_value: 5,  desc: "Scored a hattrick"},
#   { achievement_type: "underdog",    achievement_value: 5,  desc: "Game won with the least powerfull deck"},
# ])
#
