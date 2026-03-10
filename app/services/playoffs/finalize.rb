module Playoffs
  class Finalize < ApplicationService
    def call playoff_uid, winner_team_id
      Rails.logger.info "Going to close playoff ##{playoff_uid} and mark team #{winner_team_id} as winner"

      playoff = Playoff.find_by(uid: playoff_uid)
      if winner_team_id
        playoff.winner_team_id = winner_team_id
        playoff.finish!
      else
        playoff.pending!
      end

      Playoffs::Notificator.call(playoff.uid, Playoffs::Notificator::TYPE_STATE)
    end
  end
end
