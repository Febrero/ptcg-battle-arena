module Callbacks
  module PlayoffCallbacks
    def before_create(playoff)
      playoff.uid = (GameMode.max(:uid) || 0) + 1
      ::Playoffs::CalculatePrizePool.call(playoff)
      playoff.start_date = playoff.timeframes[:start_date]
      playoff.end_date = playoff.timeframes[:end_date]
    end

    def before_update(playoff)
      ::Playoffs::CalculatePrizePool.call(playoff)

      playoff.start_date = playoff.timeframes[:start_date]
      playoff.end_date = playoff.timeframes[:end_date]
    end
  end
end
