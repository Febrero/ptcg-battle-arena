module Events
  module NftsStats
    class Process
      include Callable

      def initialize(event)
        @event = event
      end

      attr_reader :event

      def call
        return if event["NFTStats"].blank?

        event["NFTStats"].each do |nft_stats|
          ["GoalLineStats", "DefenseLineStats", "AttackLineStats", "AbilitiesStats"].each do |lane|
            if nft_stats[lane]
              "TopMoments::#{lane}".constantize.create!(line_stats(nft_stats["Uuid"], nft_stats["VideoId"], nft_stats["PlayerPosition"], nft_stats[lane], lane))
            end
          end
        end
        NftsStatsInvalidateTopMomentsJob.perform_async event["WalletAddr"]
      end

      private

      def line_stats(nft_uid, video_id, position, stats, lane)
        nft_stats = {
          nft_uid: nft_uid,
          video_id: video_id,
          position: position,
          wallet_addr: event["WalletAddr"],
          game_id: event["GameId"]
        }

        stats.each do |stat_name, stat_value|
          nft_stats[stat_name.underscore.to_sym] = stat_value if "TopMoments::#{lane}".constantize.fields.has_key?(stat_name.underscore.to_s)
        end

        nft_stats
      end
    end
  end
end
