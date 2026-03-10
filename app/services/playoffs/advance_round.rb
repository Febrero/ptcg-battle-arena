module Playoffs
  class AdvanceRound
    include Callable

    attr_reader :playoff, :from_job

    def initialize(playoff_uid, from_job = false)
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @from_job = from_job
    end

    def call
      Rails.logger.info "Going to advance round for playoff ##{playoff.uid}"
      if from_job && !playoff.automatic_advance
        Rails.logger.info "Playoff[JOB] ##{playoff.uid} is in manual mode"
        return
      end

      # what happen when not yet all the games are not received??
      # we shouldnt retry job more late?
      check_missing_games

      if playoff.rounds.count > playoff.current_round
        Rails.logger.info "******************************************"
        Rails.logger.info "******************************************"
        Rails.logger.info "Going to advance to round ##{playoff.current_round + 1}"
        playoff.inc(current_round: 1)
        playoff.save

        Playoffs::Notificator.call(playoff.uid, Playoffs::Notificator::TYPE_ROUND)
        # Playoffs::Notificator.call(playoff.uid, Playoffs::Notificator::TYPE_STATE)
        next_round_timeframe = playoff.rounds.where(number: playoff.reload.current_round).first.duration
        # NOTE: he we dont put any threashold  pregame_timeframe ????

        Playoffs::AdvanceRoundJob.perform_in(next_round_timeframe.minutes, playoff.uid) if playoff.automatic_advance
        # Playoffs::AdvanceRoundJob.perform_in(next_round_timeframe, playoff_uid)
      elsif !playoff.finished?
        Playoffs::Finalize.call(playoff.uid, nil)
      end
    end

    private

    def check_missing_games
      playoff.brackets.where(round: playoff.current_round).each do |bracket|
        next if bracket.winner_team_id.present?

        team_more_older_in_playoff = nil
        bracket.teams.each do |team|
          if !team_more_older_in_playoff || team_more_older_in_playoff.created_at >= team.created_at
            team_more_older_in_playoff = team
          end
        end

        older_team_id = team_more_older_in_playoff.id.to_s

        if bracket.next_bracket
          bracket.winner_team_id = older_team_id
          bracket.winner_selected_by_system = true
          bracket.teams.each do |team|
            if team.id != older_team_id
              team.finish_playoff(bracket.round, playoff.prize_amount_by_round(bracket.round - 1))
            end
          end

          bracket.save!

          next_bracket_info = playoff.brackets.where(current_bracket: bracket.next_bracket).first

          next_bracket_info.teams_ids[next_bracket_info.previous_brackets.find_index(bracket.current_bracket)] = older_team_id
          next_bracket_info.save!

          winner_team = Playoffs::Team.find(older_team_id)
          winner_team.current_bracket_id = next_bracket_info.id.to_s
          winner_team.save!
        end
      end
    end
  end
end
