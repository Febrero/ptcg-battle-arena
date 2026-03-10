module V1
  class TutorialProgressSerializer < ActiveModel::Serializer
    attributes :wallet_addr, :wallet_addr_downcased, :completed, :completion_date, :steps

    def steps
      object.steps.map { |step| {name: step.name, created_at: step.created_at} }
    end
  end
end
