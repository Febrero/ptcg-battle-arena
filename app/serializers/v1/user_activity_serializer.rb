module V1
  class UserActivitySerializer < ActiveModel::Serializer
    attributes :wallet_addr, :event_data, :source_type, :rewards_status, :created_at, :event_date, :rewards_status

    def event_data
      case object.source_type
      when "Arena" then game_event_data
      when "Survival" then survival_event_data
      when "GameType::Quest" then daily_quest_event_data
      when "Playoff" then playoff_event_data
      end
    end

    def game_event_data
      game = Game.where(game_id: object.event_info[:game_id]).first
      game_player = game.players.find_by(wallet_addr: object.wallet_addr)

      {
        game_mode_name: game.game_mode.name,
        winner: game.winner,
        goals_scored: game_player.goals_scored,
        goals_conceded: game_player.goals_conceded
      }
    end

    def survival_event_data
      survival_player = SurvivalPlayer.where(
        wallet_addr: object.wallet_addr, "entries._id": BSON::ObjectId(object.event_info[:entry_id])
      ).hint(wallet_addr: 1).first
      entry = survival_player.entries.find(object.event_info[:entry_id])

      {
        game_mode_name: survival_player.survival.name,
        wins: entry.levels_completed
      }
    end

    def daily_quest_event_data
      {
        day: object.event_info[:day]
      }
    end

    def playoff_event_data
      team = ::Playoffs::Team.find(object.event_info[:team_id])

      {
        game_mode_name: team.playoff.name,
        wins: team.total_wins,
        has_prize: team.has_prize?,
        position: team.position
      }
    end
  end
end
