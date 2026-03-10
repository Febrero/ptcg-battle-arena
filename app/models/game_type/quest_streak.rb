module GameType
  class QuestStreak
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Pagination

    field :count, type: Integer
    field :end_date, type: DateTime
    field :claims, type: Array, default: []

    # @!attribute [rw] profile
    #   @return [GameType::QuestProfile] the class of the variable
    belongs_to :profile, class_name: "GameType::QuestProfile"

    index({end_date: 1}, {expire_after_seconds: 3600 * 24 * 365}) # 1 year on non bisext all documents will be deleted since end_date
    index({created_at: 1}, {name: "created_at_index", background: true})

    def claimed?
      last_claim = claims&.last || {}
      last_claim && last_claim[:day] == count
    end

    def pending_claim?
      !claimed?
    end

    def claim # allow claim days that will be available to be claimed
      raise "EVERYTHING_IS_CLAIMED" if claimed? # check if everything is claimed
      last_claim = claims&.last || {}

      # register claim
      # we can all persist this info in separated method, if we want ensure atomic operation
      add_to_set(claims: {day: count, date: DateTime.now.utc.to_i})

      # return all rewards that should be given to the player
      last_claim[:day] += 1 if last_claim[:day]

      profile.quest.summarize(last_claim[:day], count)
    end
  end
end
