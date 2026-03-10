module Playoffs
  class GetTeamInfo
    include Callable

    attr_reader :wallet_addr

    def initialize(wallet_addr)
      @wallet_addr = wallet_addr
    end

    def call
      Rails.cache.fetch("Playoffs::Team::#{wallet_addr}::ExtraInfo", expires_in: 5.minutes) do
        {
          avatar_url: avatar,
          level: xp_level
        }
      end
    end

    def avatar
      JSON.parse(ProfileLeaderboardsInfoSearch.new({wallets: wallet_addr}).search)[wallet_addr.downcase]["avatar_url"]
    rescue
      nil
    end

    def xp_level
      Rewards::FetchWallet.call(wallet_addr)["xp_level"]
    rescue
      nil
    end
  end
end
