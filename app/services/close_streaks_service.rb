class CloseStreaksService < ApplicationService
  def call(days_since_last_game = 2)
    # change meter em batch  e fazer lte as query
    GameType::QuestProfile.where(:last_game_played.lte => days_since_last_game.days.ago).each do |profile|
      profile.close_streak
    end
  end
end
