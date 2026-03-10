module Callbacks
  module GameType
    module QuestCallbacks
      def before_create(quest)
        quest.uid = (GameType::Quest.max(:uid) || 0) + 1 unless quest.uid
      end

      def after_save(quest)
        quest.summary = quest.summarize if quest.changes.has_key?(:config)
      end
    end
  end
end
