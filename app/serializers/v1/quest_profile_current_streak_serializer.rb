module V1
  class QuestProfileCurrentStreakSerializer < ActiveModel::Serializer
    # belongs_to :quest
    attributes :sequence, :last_game_played, :quest_uid

    def sequence
      object.count
    end

    def quest_uid
      object.quest.uid
    end
  end
end
