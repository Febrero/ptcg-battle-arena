module TopMoments
  class NftStats
    include Mongoid::Document
    include Mongoid::Timestamps
    include FieldEnumerable
    include CacheOwnership
    CACHE_OWNERSHIP_PREFIX = "Cache::NftsStats::Ownership::"

    field :uid, type: String
    field :nft_uid, type: Integer
    field :video_id, type: Integer
    field :position, type: String

    field :wallet_addr, type: String
    field :wallet_addr_downcase, type: String
    field :game_id, type: String

    # Enum values for source field
    field_enum lane: {goal_line: 0,
                      defense_line: 1,
                      attack_line: 2,
                      abilities: 3}, _prefix: true

    field :damage_dealt_attacking, type: Integer
    field :damage_dealt_defending, type: Integer
    field :overkill_damage_dealt_attacking, type: Integer
    field :overkill_damage_dealt_defending, type: Integer
    field :goals_scored, type: Integer
    field :moments_destroyed_attacking, type: Integer
    field :moments_destroyed_defending, type: Integer
    field :attacks_made, type: Integer
    field :attacks_received, type: Integer
    field :stamina_granted_with_buffs, type: Integer
    field :active_power_granted_with_buffs, type: Integer
    field :super_sub_used_after_placed, type: Integer
    field :end_of_turn_reached, type: Integer

    field :damage_received_attacking, type: Integer
    field :damage_received_defending, type: Integer
    field :overkill_damage_received_attacking, type: Integer
    field :overkill_damage_received_defending, type: Integer
    field :hattricks, type: Integer

    index({uid: 1}, {unique: true, name: "uid_index", background: true})
    index({game_id: 1}, {name: "game_id_index", background: true})
    index({nft_uid: 1}, {name: "nft_uid_index", background: true})
    index({video_id: 1}, {name: "video_id_index", background: true})
    index({position: 1}, {name: "position_index", background: true})
    index({wallet_addr_downcase: 1}, {name: "wallet_addr_downcase_index", background: true})
    index({lane: 1}, {name: "lane_index", background: true})

    # Generates an uid based on the some attributes of the event
    #
    # @note attributes used
    #   1) the game id
    #   2) the user's wallet address
    #   3) a version enabling future corrections
    #
    # @return [String] the uid generated
    #
    def generate_uid
      "#{game_id}|#{wallet_addr_downcase}|#{video_id}|#{nft_uid}|#{lane}|v1"
    end
  end
end
