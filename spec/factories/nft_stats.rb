FactoryBot.define do
  factory :nft_stats, class: "TopMoments::NftStats" do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:nft_uid)
    sequence(:video_id)
    sequence(:position) { |n| "position#{n}" }
    sequence(:wallet_addr) { |n| "wallet_addr#{n}" }
    sequence(:wallet_addr_downcase) { |n| "wallet_addr#{n}".downcase }
    sequence(:game_id) { |n| "game_id#{n}" }

    sequence(:damage_dealt_attacking)
    sequence(:damage_dealt_defending)
    sequence(:overkill_damage_dealt_attacking)
    sequence(:overkill_damage_dealt_defending)
    sequence(:goals_scored)
    sequence(:moments_destroyed_attacking)
    sequence(:moments_destroyed_defending)
    sequence(:attacks_made)
    sequence(:attacks_received)
    sequence(:stamina_granted_with_buffs)
    sequence(:active_power_granted_with_buffs)
    sequence(:super_sub_used_after_placed)
    sequence(:end_of_turn_reached)
    sequence(:damage_received_attacking)
    sequence(:damage_received_defending)
    sequence(:overkill_damage_received_attacking)
    sequence(:overkill_damage_received_defending)
  end
end
