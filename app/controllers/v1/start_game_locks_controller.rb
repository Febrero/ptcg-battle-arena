module V1
  class StartGameLocksController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::StartGameLocksControllerDoc

    prepend_before_action :authenticate_user!, only: %i[lock]
    before_action :auth_frontend, only: %i[lock]

    api :POST, "/lock", "Lock user (Authenticaded)"
    param_group :start_game_locks_controller_lock, Docs::V1::StartGameLocksControllerDoc
    def lock
      locked_until = StartGameLock::Locked.call(@user_data["publicAddress"])
      StartGameLock::Lock.call(@user_data["publicAddress"])
      render json: {locked: locked_until && locked_until > DateTime.now}, status: :ok
    end
  end
end
