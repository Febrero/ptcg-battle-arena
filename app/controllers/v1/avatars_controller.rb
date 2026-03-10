module V1
  class AvatarsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::AvatarsControllerDoc

    prepend_before_action :authenticate_user!
    before_action :auth_frontend

    api :GET, "/avatars", "List of available avatars (Authenticaded)"
    param_group :avatars_controller_index, Docs::V1::AvatarsControllerDoc
    def index
      response = GetAvatars.call(request.headers["Authorization"])
      render json: JSON.parse(response.body), status: :ok
    end
  end
end
