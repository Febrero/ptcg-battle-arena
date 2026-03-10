module Docs
  module V1
    module GreyCardsControllerDoc
      extend Apipie::DSL::Concern

      ########## PARAM GROUPS START #########
      ########## PARAM GROUPS END ###########

      ########## ACTIONS DOC START ##########
      # api :GET, "/grey_cards", "Grey Cards video info index (Authenticated)"
      def_param_group :grey_cards_controller_index do
        returns code: 200, desc: "Grey Cards metainfo for game" do
          property :uid, Integer, desc: "Video UID"
          property :rarity, Integer, desc: "Rarity of Grey Card"
          property :drop, String, desc: "Drop of Grey Card"
          property :position, String, desc: "Position of Player"
          property :defense, String, desc: "Defense of Grey Card"
          property :attack, String, desc: "Attack of Grey Card"
          property :stamina, String, desc: "Stamina of Grey Card"
          property :ball_stopper, [true, false], desc: "Ball Stopper of Grey Card"
          property :super_sub, [true, false], desc: "Super Sub of Grey Card"
          property :man_mark, Integer, desc: "Man mark of Grey Card"
          property :enforcer, [true, false], desc: "Enforcer of Grey Card"
          property :inspire, String, desc: "Inspire of grey card"
          property :captain, String, desc: "Captain of grey card"
          property :long_passer, [true, false], desc: "Long passer of grey card"
          property :box_to_box, [true, false], desc: "Box to box of grey card"
          property :dribbler, [true, false], desc: "Dribbler of grey card"
        end
      end
      ########## ACTIONS DOC END ############
    end
  end
end
