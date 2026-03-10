module Playoffs
  class OpenPlayoff < ApplicationService
    def call
      Rails.logger.info "Going to open playoffs"

      Playoff.upcoming.lte(open_date: Time.now.utc).and(automatic_advance: true, active: true).each do |playoff|
        playoff.open!
        Playoffs::Notificator.call(playoff.uid, Playoffs::Notificator::TYPE_STATE)
      end
    end
  end
end
