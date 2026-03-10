module Docs
  module V1
    module StandaloneBuildsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :standalone_builds_serializer_atributes do
        property :id, String, desc: "ID"
        property :type, String, desc: "Type"
        property :attributes, Hash, desc: "Attributes" do
          property :version, String, desc: "Version"
          property :dmg_download_url, String, desc: "DMG download URL"
          property :exe_download_url, String, desc: "EXE download URL"
          property :active, String, desc: "Active"
        end
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/standalone_builds", "Standalone builds index (authenticated)"
      def_param_group :standalone_builds_controller_index do
        returns code: 200, desc: "Success" do
          property :data, Array, desc: "Data" do
            param_group :standalone_builds_serializer_atributes, StandaloneBuildsControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end

      # api :GET, "/standalone_builds/:id", "Standalone builds detail (authenticated)"
      def_param_group :standalone_builds_controller_show do
        returns code: 200, desc: "Success" do
          param_group :standalone_builds_serializer_atributes, StandaloneBuildsControllerDoc
        end
        error code: 403, desc: "Forbidden"
      end

      # api :POST, "/standalone_builds", "Create standalone build (authenticated)"
      def_param_group :standalone_builds_controller_create do
        returns code: 200, desc: "Success" do
          param_group :standalone_builds_serializer_atributes, StandaloneBuildsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :PUT, "/standalone_builds/:id", "Update standalone build (authenticated)"
      def_param_group :standalone_builds_controller_update do
        returns code: 200, desc: "Success" do
          param_group :standalone_builds_serializer_atributes, StandaloneBuildsControllerDoc
        end
        error code: 400, desc: "Bad request"
        error code: 403, desc: "Forbidden"
      end

      # api :DELETE, "/standalone_builds/:id", "Delete standalone build (authenticated)"
      def_param_group :standalone_builds_controller_destroy do
        returns code: 204, desc: "No content"
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
