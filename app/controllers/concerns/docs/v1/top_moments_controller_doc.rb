module Docs
  module V1
    module TopMomentsControllerDoc
      extend Apipie::DSL::Concern

      ########## ACTIONS DOC START ##########
      # api :GET, "/top_moments", "List of top moments by wallet addr (Authenticated)"
      def_param_group :top_moments_controller_show do
        returns code: 200, desc: "Top Moments" do
          property :goal_line_stats, Array, desc: "Array of goal line stats" do
            property :goals_avoided, Integer, desc: "Number of goals avoided"
            property :opponents_destroyed, Integer, desc: "Number of opponents destroyed"
            property :turns_played, Integer, desc: "Number of turns played"
            property :video_id, Integer, desc: "ID of the video"
            property :rarity, String, desc: "Rarity of the grey|other"
            # Add more properties here if needed
          end
          property :defense_line_stats, Array, desc: "Array of defense line stats" do
            property :damage_absorved, Integer, desc: "Amount of damage absorbed"
            property :opponents_destroyed, Integer, desc: "Number of opponents destroyed"
            property :turns_played, Integer, desc: "Number of turns played"
            property :video_id, Integer, desc: "ID of the video"
            property :rarity, String, desc: "Rarity of the grey|other"
            # Add more properties here if needed
          end
          property :attack_line_stats, Array, desc: "Array of attack line stats" do
            property :goals_scored, Integer, desc: "Number of goals scored"
            property :damage_dealt, Integer, desc: "Amount of damage dealt"
            property :opponents_destroyed, Integer, desc: "Number of opponents destroyed"
            property :video_id, Integer, desc: "ID of the video"
            property :rarity, String, desc: "Rarity of the grey|other"
            # Add more properties here if needed
          end
        end
        error code: 403, desc: "Forbidden"
      end
      ########## ACTIONS DOC END ############
    end
  end
end
