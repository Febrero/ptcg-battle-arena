module TutorialProgresses
  class NewStep < ApplicationService
    def call(wallet_addr, step_name)
      tutorial_progress = TutorialProgress.find_or_initialize_by(
        wallet_addr: wallet_addr,
        wallet_addr_downcased: wallet_addr.downcase
      )

      unless tutorial_progress.step_completed?(step_name)
        new_step = TutorialProgresses::Step.new({name: step_name})
        tutorial_progress.steps << new_step
      end

      tutorial_progress.completed = tutorial_progress.tutorial_completed?

      tutorial_progress.save

      tutorial_progress
    end
  end
end
