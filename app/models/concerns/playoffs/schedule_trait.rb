module Playoffs
  module ScheduleTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def schedule_ongoing_event_change
      if automatic_advance
        diff_in_seconds = (Time.now.utc - open_date).to_i
        Playoffs::PregamePlayoffJob.perform_in(((open_timeframe * 60) - diff_in_seconds).seconds, uid)
        Playoffs::StartPlayoffJob.perform_in((((open_timeframe + pregame_timeframe) * 60) - diff_in_seconds).seconds, uid)
      end
    end

    private

    def schedule_advance_round_event
      Playoffs::Notificator.call(uid, Playoffs::Notificator::TYPE_ROUND)
      Playoffs::Notificator.call(uid, Playoffs::Notificator::TYPE_STATE)

      if automatic_advance
        reload
        round_advance_timeframe = rounds.where(number: current_round).first.duration

        # Playoffs::AdvanceRoundJob.perform_in((pregame_timeframe + round_advance_timeframe), uid)
        Playoffs::AdvanceRoundJob.perform_in(round_advance_timeframe.minutes, uid)
      end
    end
  end
end
