module Callbacks
  module Playoffs
    module TeamCallbacks
      def before_create(team)
        team.wallet_addr_downcased = team.wallet_addr.downcase if team.wallet_addr
      end

      def after_create(team)
        playoff = team.playoff
        playoff.registered_profile_ids = playoff.teams.order_by(created_at: :asc).map { |t| t.profile_id }
        playoff.save(validate: false)
      end
    end
  end
end
