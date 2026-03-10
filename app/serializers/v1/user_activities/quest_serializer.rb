module V1
  module UserActivities
    class QuestSerializer < ActiveModel::Serializer
      attributes :day

      def day
        object.event_info[:day]
      end
    end
  end
end
