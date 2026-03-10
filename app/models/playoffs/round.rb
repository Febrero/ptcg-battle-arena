module Playoffs
  class Round
    include Mongoid::Document

    MIN_ROUND_DURATION = 1

    field :number, type: Integer
    field :duration, type: Integer, default: MIN_ROUND_DURATION

    validates :number, presence: true
    validates :duration, presence: true

    validate :validate_duration

    embedded_in :playoff, class_name: "Playoff"

    def validate_duration
      if duration < MIN_ROUND_DURATION
        errors.add(:duration, "The minimun duration for round is: #{MIN_ROUND_DURATION}")
      end
    end
  end
end
