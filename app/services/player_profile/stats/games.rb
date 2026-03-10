class PlayerProfile::Stats::Games < ApplicationService
  attr_reader :wallet_addr

  def call(wallet_addr)
    @wallet_addr = wallet_addr

    {
      "seconds_played" => seconds_played,
      "total_games" => total_games,
      "total_wins" => total_wins,
      "wins_average" => wins_average
    }
  end

  private

  def seconds_played
    @seconds_played ||= Game.in(players_wallet_addresses: wallet_addr).sum(:game_duration) / 1000
  end

  def total_games
    @total_games ||= GamePlayer.where(wallet_addr: wallet_addr).count
  end

  def total_wins
    @total_wins ||= GamePlayer.where(wallet_addr: wallet_addr, winner: true).count
  end

  def wins_average
    return 0 if total_games.zero?

    (total_wins.to_f / total_games.to_f) * 100
  end
end
