module AfterParty
  class GeneratePastUserActivity
    def call
      fails = []
      Rails.logger.info "Generating games activity"
      Game.where(match_type: "Arena").all.each do |game|
        game.players.each do |player|
          ua = UserActivity.where(wallet_addr: player.wallet_addr, event_info: { game_id: game.game_id}, source: game.game_mode).first_or_create(
            season_uid: Season.where(active: true, :start_date.lte => Time.at(game.game_end_time / 1000).to_datetime).order(start_date: :desc).first,
            event_date: Time.at(game.game_end_time / 1000).to_datetime,
            created_at: Time.at(game.game_end_time / 1000).to_datetime
          )
          if ua.errors.present?
            fails.push(ua)
          end
        end
      end

      Rails.logger.info "Generating survivals activity"
      SurvivalPlayer.all.each do |survival_player|
        survival_player.entries.each do |entry|
          ua = UserActivity.where(
            wallet_addr: survival_player.wallet_addr, 
            event_info: { entry_id: entry.id.to_s}, 
            source: survival_player.survival)
          .first_or_create(
            event_date: entry.closed_at,
            season_uid: Season.where(active: true, :start_date.lte => entry.closed_at).order(start_date: :desc).first,
            created_at: entry.closed_at
          )

          if ua.errors.present?
            fails.push(ua)
          end
        end
      end

      Rails.logger.info "Generating daily quest streak activity"
      GameType::QuestStreak.all.each do |quest_streak|
        quest_streak.claims.each do |claim|
          UserActivity.where(
            wallet_addr: quest_streak.profile.wallet_addr,
            event_info: { day: claim["day"], quest_streak_id: quest_streak.id.to_s },
            source: quest_streak.profile.quest,
          ).first_or_create(
            event_date: claim["date"],
            season_uid: Season.where(active: true, :start_date.lte => claim["date"]).order(start_date: :desc).first,
            created_at: claim["date"]
          )

          if ua.errors.present?
            fails.push(ua)
          end
        end
      end

      return fails
    end
  end
end