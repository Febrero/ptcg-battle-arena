module Playoffs
  module RollbackTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def rollback_to_round(to_round, timestamp_utc = nil)
      total_rounds = rounds.count
      raise "InvalidRoundNumber" if to_round < 0 || to_round > rounds.count
      raise "InvalidState" if finished? || admin_pending?

      total_rounds.downto(to_round).each do |round_number|
        brackets.where(round_number: round_number).each do |bracket|
          bracket.reset

          if (round_number == to_round && round_number > 1) || (round_number == 2 && to_round == 1)
            bracket.previous_brackets.each_with_index do |current_bracket, array_pos|
              winner_team_id = brackets.where(current_bracket: current_bracket).first.winner_team_id
              bracket.teams_ids[array_pos] = winner_team_id if winner_team_id
            end
            bracket.save
          end
        end
      end

      scheduled_jobs = Sidekiq::ScheduledSet.new
      scheduled_jobs.each do |job|
        job.delete if job.klass == "Playoffs::AdvanceRoundJob" && job.args.include?(uid)
      end

      self.current_round = to_round
      save
      pause!

      Playoffs::ContinueJob.perform_in((timestamp_utc - Time.now.utc.to_i), uid) if timestamp_utc
    end

    def continue_at(timestamp_utc)
      if troubleshooting?
        Playoffs::ContinueJob.perform_in((timestamp_utc - Time.now.utc.to_i), uid)
      end
    end

    def pause_it
      scheduled_jobs = Sidekiq::ScheduledSet.new
      scheduled_jobs.each do |job|
        job.delete if job.klass == "Playoffs::AdvanceRoundJob" && job.args.include?(uid)
      end

      pause!
      save
    end
  end
end
