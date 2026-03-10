class GetGamesInfo < ApplicationService
  def call
    [
      pvp,
      pve,
      *arenas,
      total
    ]
  end

  private

  def pvp
    {name: "PVP", count: Game.match_count("PVP", -1)}
  end

  def pve
    {name: "PVE", count: Game.match_count("PVE", -2)}
  end

  def arenas
    Arena.all.map { |arena| {name: arena.name, count: Game.match_count("Arena", arena.uid)} }
  end

  def total
    {name: "Total", count: Game.count}
  end
end
