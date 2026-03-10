module GameType
  class QuestProfile
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Pagination

    field :wallet_addr, type: String

    # @!attribute [rw] quest
    #   @return [GameType::Quest] the class of the variable
    # belongs_to :quest, primary_key: "uid", class_name: "GameType::Quest", optional: true
    belongs_to :quest, foreign_key: :quest_id, primary_key: :uid, class_name: "GameType::Quest", optional: true

    has_many :streaks, class_name: "GameType::QuestStreak"
    field :days_to_rewards, type: Array, default: []
    field :claims, type: Array, default: []
    field :count, type: Integer, default: 0
    field :last_game_played, type: Date # this is the last the datetiem that count to the questprofile
    field :last_try, type: DateTime #

    validates :wallet_addr, presence: true
    validates :quest, presence: true

    index({wallet_addr: 1}, {name: "wallet_addr_index", background: true})
    index({quest_id: 1}, {name: "quest_id_index", background: true})
    index({wallet_addr: 1, quest_id: 1}, {name: "wallet_quest_index", background: true, unique: true})

    def current_quest_streak
      streaks.where(end_date: nil).first
    end

    def new_milestone(new_game_date)
      update(last_try: new_game_date)
      new_game_date = new_game_date.to_date
      n_days = nil
      # calculate number of days between matchs
      n_days = (new_game_date - last_game_played).to_i if last_game_played
      rewards_to_be_claimed = {}

      if n_days.nil? || n_days > 0
        close_streak if n_days.to_i > 1 || is_last_day_of_quest
        rewards_to_be_claimed = update_actual_streak(new_game_date)
      end

      [rewards_to_be_claimed, count, current_quest_streak.id]
    end

    def is_last_day_of_quest
      count == quest.config.count
    end

    def update_actual_streak(new_game_date)
      if count == 0 && current_quest_streak.nil?
        QuestStreak.create(profile: self, count: 0, claims: [], end_date: nil)
      end

      update(last_game_played: new_game_date) # update current game date on document
      inc(count: 1) # increment sequence of days playing consecutive
      add_to_set(days_to_rewards: count) # increment array of days that will be available to be claimed
      UserActivity.create(
        wallet_addr: wallet_addr,
        event_info: {day: count, quest_streak_id: current_quest_streak.id.to_s},
        source: quest,
        event_date: Time.now,
        season_uid: Season.currently_active.first.uid
      )
      claim
      # do not close streak in last game that he played
      # close_streak if is_last_day_of_quest # if is the last day of quest we should close the streak
    end

    def close_streak
      current_quest_streak.update(count: count, end_date: last_game_played, claims: claims)
      reset_current_streak
    end

    def claim # claim only the last day available to be claimed
      day_to_be_claimed = days_to_rewards&.last  # last day in sequence registered to be claimed

      raise "NO_DAYS_TO_BE_CLAIMED" unless day_to_be_claimed

      last_claim = claims&.last || {}

      # register claim

      # we can all persist this info in separated method, if we want ensure atomic operation
      add_to_set(claims: {day: day_to_be_claimed, date: DateTime.now.utc.to_i})

      last_day_claimed = last_claim[:day]
      # if day was claimed to i want rewards since next day
      last_day_claimed += 1 if last_day_claimed

      # return all rewards that should be given to the player
      quest.summarize(last_day_claimed, day_to_be_claimed)
    end

    def reset_current_streak
      update(count: 0, days_to_rewards: [], claims: [], last_game_played: nil)
    end
  end
end
