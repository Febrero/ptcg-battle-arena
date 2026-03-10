module V1
  class UserActivityDetailSerializer < ActiveModel::Serializer
    attributes :wallet_addr, :event_data, :source_type, :created_at, :event_date, :rewards, :rewards_status
    def event_data
      case object.source_type
      when "Arena"
        game = Game.find_by(game_id: object.event_info[:game_id])
        UserActivities::GameSerializer.new(game)

      when "Survival"
        survival_player = SurvivalPlayer.where(wallet_addr: object.wallet_addr)
          .where("entries._id": BSON::ObjectId(object.event_info[:entry_id]))
          .hint(wallet_addr: 1)
          .first

        entry = survival_player.entries.find(object.event_info[:entry_id])

        UserActivities::SurvivalSerializer.new(entry)

      when "GameType::Quest"
        UserActivities::QuestSerializer.new(object)

      when "Playoff"
        team = ::Playoffs::Team.find(object.event_info[:team_id])

        UserActivities::PlayoffSerializer.new(team.playoff, {team: team})
      end
    end

    def rewards
      object.rewards.map do |r|
        {
          status: r.status,
          reward_type: r.reward_type,
          reward_subtype: r.reward_subtype,
          value: r.value,
          image_url: ::UserActivities::FetchRewardImageUrl.call(r)
        }
      end
    end
  end
end
