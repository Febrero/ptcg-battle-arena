module V1
  module UserActivities
    class GamePlayerSerializer < ActiveModel::Serializer
      attributes :goals_scored, :outcome, :level

      attribute :username, if: -> { profiles.present? }
      attribute :avatar_url, if: -> { profiles.present? }

      def username
        profile_info["attributes"]["username"]
      end

      def avatar_url
        avatar_info["attributes"]["url"]
      end

      def level
        profile_info["attributes"]["xp_level"]
      end

      def profile_info
        @profile_info ||= profiles["data"].find do |item|
          item["attributes"]["wallet_addr"] == object.wallet_addr
        end
      end

      def avatar_info
        @avatar_info ||= profiles["included"].find do |item|
          item["id"] == profile_info["relationships"]["avatar"]["data"]["id"] && item["type"] == "avatars"
        end
      end

      def profiles
        @profiles ||= instance_options[:profiles]
      end
    end
  end
end
