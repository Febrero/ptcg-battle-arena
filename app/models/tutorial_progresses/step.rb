module TutorialProgresses
  class Step
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String

    validates :name, presence: true

    validate :validate_step_name_existence, on: :create

    def validate_step_name_existence
      unless TutorialProgress::STEPS.include?(name)
        errors.add(:name, "invalid step name")
      end
    end

    embedded_in :tutorial_progress, class_name: "TutorialProgress"
  end
end
