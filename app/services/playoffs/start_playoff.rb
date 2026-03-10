module Playoffs
  class StartPlayoff < ApplicationService
    def call playoff_uid
      Rails.logger.info "Going to start playoff ##{playoff_uid}"
      playoff = Playoff.find_by(uid: playoff_uid.to_i)
      if playoff.start!
        Playoffs::Notificator.call(playoff_uid.to_i, Playoffs::Notificator::TYPE_STATE)
      end
    end
  end
end
