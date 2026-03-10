module Callbacks
  module SeasonCallbacks
    def before_create(season)
      season.uid = (Season.max(:uid) || 0) + 1 unless season.uid
    end
  end
end
