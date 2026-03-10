module Playoffs
  class Continue
    include Callable

    attr_reader :playoff, :from_job

    def initialize(playoff_uid, from_job = false)
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @from_job = from_job
    end

    def call
      playoff.continue!
      Playoffs::Notificator.call(playoff.uid, Playoffs::Notificator::TYPE_ROUND)
      next_round_timeframe = playoff.rounds.where(number: playoff.reload.current_round).first.duration
      Playoffs::AdvanceRoundJob.perform_in(next_round_timeframe.minutes, playoff.uid) if playoff.automatic_advance
    end
  end
end
