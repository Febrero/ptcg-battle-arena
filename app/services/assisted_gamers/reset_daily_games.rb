module AssistedGamers
  class ResetDailyGames < ApplicationService
    def call
      AssistedGamer.update_all(todays_total_games_played: 0)
    end
  end
end
