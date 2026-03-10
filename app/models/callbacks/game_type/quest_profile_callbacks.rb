module Callbacks
  module GameType
    module QuestProfileCallbacks
      def after_update(quest_profile)
        quest_profile.current_quest_streak&.update(
          count: quest_profile.count,
          claims: quest_profile.claims
        )
      end
    end
  end
end
