module Docs
  module V1
    module StartGameLocksControllerDoc
      extend Apipie::DSL::Concern

      # api :POST, "/start_game_locks/lock", "Lock user"
      def_param_group :start_game_locks_controller_lock do
        returns code: 200, desc: "Success"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
