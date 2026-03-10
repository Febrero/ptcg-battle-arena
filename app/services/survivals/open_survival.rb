module Survivals
  class OpenSurvival < ApplicationService
    def call
      Rails.logger.info "Going to open survivals that should start"
      Rails.logger.info "Survival.incoming.lte(start_date: #{Time.now})"
      Rails.logger.info Survival.incoming.lte(start_date: Time.now).count
      Rails.logger.info Survival.incoming.lte(start_date: Time.now).all.to_a
      Rails.logger.info Survival.incoming.lte(start_date: Time.now.utc).count
      Rails.logger.info Survival.incoming.lte(start_date: Time.now.utc).all.to_a
      Survival.incoming.lte(start_date: Time.now.utc).each do |survival|
        Rails.logger.info survival
        survival.open!
      end
    end
  end
end
