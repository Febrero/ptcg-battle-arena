module TutorialProgresses
  class GetUserProgress < ApplicationService
    def call(wallet_addr)
      wallet_addr.downcase!

      tutorial_progress = TutorialProgress.where(wallet_addr_downcased: wallet_addr).first

      if tutorial_progress.present? && tutorial_progress.steps.present?
        tutorial_progress.completed ? "done" : tutorial_progress.steps.last.name
      end
    end
  end
end
