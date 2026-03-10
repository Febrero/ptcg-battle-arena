module Callbacks
  module SurvivalCallbacks
    def before_create(survival)
      survival.uid = (GameMode.max(:uid) || 0) + 1
    end
  end
end
