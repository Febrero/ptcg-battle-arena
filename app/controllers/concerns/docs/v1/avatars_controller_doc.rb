module Docs
  module V1
    module AvatarsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/avatars", "List of available avatars for profile (Authenticaded)"
      def_param_group :avatars_controller_index do
        returns code: 200, desc: "Avatar" do
          property :data, Array, desc: "Avatar" do
            property :uid, Integer, desc: "UID of the avatar"
            property :url, String, desc: "Image S3 URL"
            property :price, Float, desc: "Avatar price"
          end
        end
        error code: 403, desc: "Unauthorized"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
