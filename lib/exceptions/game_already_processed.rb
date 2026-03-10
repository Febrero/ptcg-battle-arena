class GameAlreadyProcessed < StandardError
  def initialize(game)
    @game_id = game.game_id
  end

  def to_s
    "Game #{@game_id} already processed and a new event came with no correction flag"
  end
end
