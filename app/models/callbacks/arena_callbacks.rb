module Callbacks
  module ArenaCallbacks
    def before_create(arena)
      arena.uid = (GameMode.max(:uid) || 0) + 1
    end
  end
end
