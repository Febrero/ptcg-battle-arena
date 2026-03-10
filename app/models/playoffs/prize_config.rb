module Playoffs
  class PrizeConfig
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Pagination

    field :uid, type: Integer
    field :config, type: Hash, default: {}
    field :active, type: Boolean
    field :name, type: String
    has_many :playoffs, inverse_of: :playoff, foreign_key: :playoff_id, primary_key: :uid, class_name: "Playoff"

    index({prize_config_id: 1}, {name: "prize_config_id_index", background: true})
  end
end

## if we put prize_percentage it willbase on pool if we have prize_unit it will base on number of units

# {
#   2 => [{
#     rounds_completed: 1,
#     prize_percentage: 100
#   }],
#   4 => [
#     {
#       rounds_completed: 2,
#       prize_percentage: 100
#     }
#   ],
#   8 => [
#     {
#       rounds_completed: 3,
#       prize_percentage: 70
#     },
#     {
#       rounds_completed: 2,
#       prize_percentage: 30
#     }
#   ],
#   16 => [
#     {
#       rounds_completed: 4,
#       prize_percentage: 50
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 30
#     },
#     {
#       rounds_completed: 2,
#       prize_percentage: 20
#     }
#   ],
#   32 => [
#     {
#       rounds_completed: 5,
#       prize_percentage: 40
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 25
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 20
#     },
#     {
#       rounds_completed: 2,
#       prize_percentage: 15
#     }
#   ],
#   64 => [
#     {
#       rounds_completed: 6,
#       prize_percentage: 40
#     },
#     {
#       rounds_completed: 5,
#       prize_percentage: 25
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 20
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 15
#     }
#   ],
#   128 => [
#     {
#       rounds_completed: 7,
#       prize_percentage: 32.5
#     },
#     {
#       rounds_completed: 6,
#       prize_percentage: 20
#     },
#     {
#       rounds_completed: 5,
#       prize_percentage: 17.5
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 15
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 15
#     }
#   ],
#   256 => [
#     {
#       rounds_completed: 8,
#       prize_percentage: 27.5
#     },
#     {
#       rounds_completed: 7,
#       prize_percentage: 17.5
#     },
#     {
#       rounds_completed: 6,
#       prize_percentage: 15
#     },
#     {
#       rounds_completed: 5,
#       prize_percentage: 15
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 12.5
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 12.5
#     }
#   ],
#   512 => [
#     {
#       rounds_completed: 9,
#       prize_percentage: 25
#     },
#     {
#       rounds_completed: 8,
#       prize_percentage: 15
#     },
#     {
#       rounds_completed: 7,
#       prize_percentage: 14
#     },
#     {
#       rounds_completed: 6,
#       prize_percentage: 14
#     },
#     {
#       rounds_completed: 5,
#       prize_percentage: 13
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 12
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 10
#     }
#   ],
#   1024 => [
#     {
#       rounds_completed: 10,
#       prize_percentage: 23
#     },
#     {
#       rounds_completed: 9,
#       prize_percentage: 14.5
#     },
#     {
#       rounds_completed: 8,
#       prize_percentage: 13
#     },
#     {
#       rounds_completed: 7,
#       prize_percentage: 12
#     },
#     {
#       rounds_completed: 6,
#       prize_percentage: 11
#     },
#     {
#       rounds_completed: 4,
#       prize_percentage: 10
#     },
#     {
#       rounds_completed: 3,
#       prize_percentage: 9
#     }
#   ],
#   2048 => [
#     {
#       rounds_completed: 12,
#       prize_percentage: 21
#     },
#     {
#       rounds_completed: 11,
#       prize_percentage: 13
#     },
#     {
#       rounds_completed: 10,
#       prize_percentage: 12
#     },
#     {
#       rounds_completed: 9,
#       prize_percentage: 11
#     },
#     {
#       rounds_completed: 8,
#       prize_percentage: 10
#     },
#     {
#       rounds_completed: 7,
#       prize_percentage: 9
#     },
#     {
#       rounds_completed: 6,
#       prize_percentage: 8.5
#     }
#   ],
#   4096 => [
#     {
#       rounds_completed: 13,
#       prize_percentage: 18.1
#     },
#     {
#       rounds_completed: 12,
#       prize_percentage: 10.7
#     },
#     {
#       rounds_completed: 11,
#       prize_percentage: 10.3
#     },
#     {
#       rounds_completed: 10,
#       prize_percentage: 9.9
#     },
#     {
#       rounds_completed: 9,
#       prize_percentage: 9.5
#     },
#     {
#       rounds_completed: 8,
#       prize_percentage: 9.1
#     },
#     {
#       rounds_completed: 7,
#       prize_percentage: 8.7
#     }
#   ]
# }
# current_bracket: total_brackets,
# next_bracket: nil,
# teams: [],
# round
