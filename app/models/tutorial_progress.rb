class TutorialProgress
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  STEPS = [
    "tutorial_training",
    "tutorial_friendly"
  ]

  field :wallet_addr, type: String
  field :wallet_addr_downcased, type: String
  field :completed, type: Boolean, default: false
  field :completion_date, type: DateTime

  embeds_many :steps, class_name: "TutorialProgresses::Step", cascade_callbacks: true

  validates :wallet_addr, :wallet_addr_downcased, uniqueness: true

  index({wallet_addr: 1}, {name: "wallet_addr_index", background: true, unique: true})
  index({wallet_addr_downcased: 1}, {name: "wallet_addr_downcased_index", background: true, unique: true})
  index({completed: 1}, {name: "completed_index", background: true})
  index({wallet_addr: 1, "steps.name": 1}, {name: "wallet_addr_steps_name_index", unique: true, background: true})

  # checks if tutorial is completed considering the current STEPS constant
  def tutorial_completed?
    step_completed?(STEPS.last)
  end

  # checks if a step is already completed
  def step_completed?(step_name)
    steps.where(name: step_name).present?
  end
end
