class LeaderboardsSearch
  attr_accessor :source, :time_range, :season_survival_arena_playoff, :params

  def initialize(source, time_range, season_survival_arena_playoff, params)
    @source = source
    @time_range = time_range
    @params = params
    @season_survival_arena_playoff = season_survival_arena_playoff
  end

  def search
    extra_parameters = "/#{season_survival_arena_playoff}" if season_survival_arena_playoff
    InternalApi
      .new
      .get(
        "leaderboards",
        request_uri: "/leaderboards/#{source}/#{time_range}#{extra_parameters}",
        query: params
      )
      .json
  end

  def self.game_modes_profile(wallet_addr, season)
    filter_season = (!season.nil?) ? "?filter[season]=#{season}" : ""

    InternalApi
      .new
      .get(
        "leaderboards",
        request_uri: "/leaderboards/battle_arena/game_modes/#{wallet_addr}#{filter_season}",
        query: {}
      )
      .json
  end
end
