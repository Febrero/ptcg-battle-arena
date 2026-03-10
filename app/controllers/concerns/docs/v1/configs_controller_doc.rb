module Docs
  module V1
    module ConfigsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      def_param_group :config_attributes do
        property :version, String, desc: "Version"
        property :translations, Hash, desc: "Translations"
        property :links, Integer, desc: "Links"
        property :decks, Hash, desc: "Decks rules, etc"
      end
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/configs", "Configs (Authenticaded)"
      def_param_group :configs_controller_index do
        returns code: 200, desc: "Config" do
          property :data, Array, desc: "Config" do
            param_group :config_attributes, ConfigsControllerDoc
          end
        end
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
