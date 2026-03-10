module NftStats
  class GenerateTopMoments
    include Callable

    def initialize(wallet_addr)
      @wallet_addr = wallet_addr.downcase
    end

    attr_reader :wallet_addr

    def call
      Rails.cache.fetch("TopMoments::NftsStats::#{wallet_addr}::#{TopMoments::NftStats.ownership_last_updated_at(wallet_addr)}", expires_in: 1.day) do
        top_moments = {}
        top_3_moments_by_lane = {}
        TopMoments::NftStats.where(wallet_addr_downcase: wallet_addr).batch_size(500).each do |nft_stats|
          lane = nft_stats._type
          video_id = nft_stats.video_id
          nft_uid = nft_stats.nft_uid
          rarity = (nft_uid.to_i < 0) ? "grey" : "other"
          video_type = "#{video_id}##{rarity}"

          lane = lane.split("::")[1].underscore

          next if !["goal_line_stats", "defense_line_stats", "attack_line_stats"].include?(lane)

          top_moments[lane] ||= {}
          top_moments[lane][video_type] = send(lane, top_moments[lane][video_type], nft_stats, video_id, rarity, video_type)
          current_moment = top_moments[lane][video_type]
          top_3_moments_by_lane[lane] ||= []

          if top_3_moments_by_lane[lane].length < 3 || current_moment[:sorting_field] > top_3_moments_by_lane[lane][-1][:sorting_field]
            index = top_3_moments_by_lane[lane].index { |moment| moment[:video_type] == video_type }
            if index.nil?
              top_3_moments_by_lane[lane] << current_moment
            else
              top_3_moments_by_lane[lane][index] = current_moment
            end

            # Sort the moments based on sorting_field in descending order
            top_3_moments_by_lane[lane].sort_by! { |moment| -BigDecimal(moment[:sorting_field]) }
            top_3_moments_by_lane[lane] = top_3_moments_by_lane[lane].take(3)
          end
        end

        top_3_moments_by_lane.each do |key, values|
          values.reject! { |entry| entry[:sorting_field] =~ /\A0+\z/ }
          values.each do |entry|
            entry.delete(:sorting_field)
            entry.delete(:video_type)
          end
        end

        top_3_moments_by_lane
      end
    end

    private

    def goal_line_stats(current, nft_stats, video_id, rarity, video_type)
      current ||= {goals_avoided: 0, opponents_destroyed: 0, turns_played: 0, video_id: video_id, rarity: rarity, video_type: video_type}
      current[:goals_avoided] += nft_stats.attacks_received.to_i
      current[:opponents_destroyed] += (nft_stats.moments_destroyed_attacking.to_i + nft_stats.moments_destroyed_defending.to_i)
      current[:turns_played] += nft_stats.end_of_turn_reached.to_i
      current[:sorting_field] = "#{current[:goals_avoided].to_s.rjust(6, "0")}#{current[:opponents_destroyed].to_s.rjust(6, "0")}#{current[:turns_played].to_s.rjust(6, "0")}"
      current
    end

    def defense_line_stats(current, nft_stats, video_id, rarity, video_type)
      current ||= {damage_absorved: 0, opponents_destroyed: 0, turns_played: 0, video_id: video_id, rarity: rarity, video_type: video_type}
      current[:damage_absorved] += nft_stats.damage_received_defending.to_i
      current[:opponents_destroyed] += (nft_stats.moments_destroyed_attacking.to_i + nft_stats.moments_destroyed_defending.to_i)
      current[:turns_played] += nft_stats.end_of_turn_reached.to_i
      current[:sorting_field] = "#{current[:damage_absorved].to_s.rjust(6, "0")}#{current[:opponents_destroyed].to_s.rjust(6, "0")}#{current[:turns_played].to_s.rjust(6, "0")}"
      current
    end

    def attack_line_stats(current, nft_stats, video_id, rarity, video_type)
      current ||= {goals_scored: 0, damage_dealt: 0, opponents_destroyed: 0, video_id: video_id, rarity: rarity, video_type: video_type}
      current[:goals_scored] += nft_stats.goals_scored.to_i
      current[:damage_dealt] += (nft_stats.damage_dealt_attacking.to_i - nft_stats.overkill_damage_dealt_attacking.to_i)
      current[:opponents_destroyed] += (nft_stats.moments_destroyed_attacking.to_i + nft_stats.moments_destroyed_defending.to_i)

      # negative corner
      damage_dealt = current[:damage_dealt].abs
      if current[:damage_dealt] > 0
        damage_dealt = current[:damage_dealt] * 1000
      end
      current[:sorting_field] = "#{current[:goals_scored].to_s.rjust(6, "0")}#{damage_dealt.to_s.rjust(10, "0")}#{current[:opponents_destroyed].to_s.rjust(6, "0")}"
      current
    end
  end
end
