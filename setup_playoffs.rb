Playoff.delete_all
Playoffs::PrizeConfig.delete_all

prize_config = Playoffs::PrizeConfig
  .create(
    active: true,
    name: "Prize Config",
    config:
    {
      2 => [{
        rounds_completed: 1,
        prize_percentage: 100
      }],
      4 => [
        {
          rounds_completed: 2,
          prize_percentage: 100
        }
      ],
      8 => [
        {
          rounds_completed: 3,
          prize_percentage: 70
        },
        {
          rounds_completed: 2,
          prize_percentage: 30
        }
      ],
      16 => [
        {
          rounds_completed: 4,
          prize_percentage: 50
        },
        {
          rounds_completed: 3,
          prize_percentage: 30
        },
        {
          rounds_completed: 2,
          prize_percentage: 20
        }
      ],
      32 => [
        {
          rounds_completed: 5,
          prize_percentage: 40
        },
        {
          rounds_completed: 4,
          prize_percentage: 25
        },
        {
          rounds_completed: 3,
          prize_percentage: 20
        },
        {
          rounds_completed: 2,
          prize_percentage: 15
        }
      ]
    }
  )

[
  {
    state: "upcoming",
    name: "upcoming playoff",
    active: true,
    open_date: (Time.now + 2.months)
  },
  {
    state: "opened",
    name: "open playoff",
    active: true,
    open_date: (Time.now - 1.hour)
  },
  {
    state: "ongoing",
    name: "ongoing playoff",
    active: true,
    open_date: (Time.now - 1.hour)
  },
  {
    state: "finished",
    name: "finished playoff",
    active: true,
    open_date: (Time.now - 1.day)
  }
].each do |p_info|
  p_info.merge!({
    open_timeframe: 3,
    pregame_timeframe: 3,
    min_deck_tier: 2,
    default_round_duration: 5,
    total_prize_pool: 10000.0,
    prize_pool_winner_share: 5000.0,
    prize_pool_realfevr_share: 5000.0,
    compatible_ticket_ids: ["1"],
    erc20_name: "FEVR",
    prize_config: prize_config
  })
  pp p_info
  Playoff.create!(p_info)
end

playoff = Playoff.opened.first

Playoffs::Team.delete_all
teams = []
(1..8).each do |team|
  teams << Playoffs::Team.create!(playoff: playoff, wallet_addr: "---#{team}")
end

playoff.brackets.delete_all
playoff.reload

Playoffs::GenerateBrackets.new(playoff.uid, false).call

playoff.reload.brackets.each do |b|
  # puts "\t\t#{b.inspect}"
  puts "#{b.current_bracket} - #{b.next_bracket}"
end

def bracket_info brackets, bracket = brackets.shift
  return bracket.attributes if bracket.round == 1

  bracket_h = bracket.attributes.merge({"child_brackets" => []})

  brackets.select { |b| b.next_bracket == bracket.current_bracket }.each do |child_bracket|
    bracket_h["child_brackets"] << bracket_info(brackets, brackets.delete(child_bracket))
  end

  p bracket_h
end

playoff = Playoff.ongoing.first
bracket_info(Playoffs::Bracket.where(playoff_id: playoff.uid).order(current_bracket: :desc).all.to_a)

## create teams for create a simulation playoff

playoff_demo = {
  state: "ongoing",
  name: "ongoing playoff",
  active: true,
  open_date: (Time.now - 1.hour),
  open_timeframe: 3,
  pregame_timeframe: 3,
  min_deck_tier: 2,
  default_round_duration: 5
}

playoff_demo.merge!({
  total_prize_pool: 10000.0,
  prize_pool_winner_share: 5000.0,
  prize_pool_realfevr_share: 5000.0,
  compatible_ticket_ids: ["1"],
  erc20_name: "FEVR"
})

playoff = Playoff.create!(p_info)

pvp_games = Game.where(game_mode_id: -2).order_by(created_at: :desc).limit(3)
pve_game = Game.where(game_mode_id: -1).order_by(created_at: :desc).limit(1)

all_games = pvp_games + pve_game

all_teams_versus = []

all_games.each do |game|
  versus = {game_id: game.id, current_bracket: nil, game: game, game_details: game.to_original_request, teams: []}

  game.players.all.each do |player|
    team = Playoffs::Team.create!(playoff: playoff, wallet_addr: player.wallet_addr)
    versus[:teams] << team.id
  end

  if game.players.count == 1
    versus[:teams] << nil
  end

  all_teams_versus << versus
end

Playoffs::GenerateBrackets.new(playoff.uid, false).call

playoff.reload!

playoff.brackets.each do |index, bracket|
  bracket.teams_ids = all_teams_versus[index][:teams]
  bracket.save!

  if all_teams_versus[index][:teams].include? nil
    next_bracket = playoff.brackets.where(current_bracket: bracket.next_bracket).first
    next_bracket.teams_ids << all_teams_versus[index][0]
    next_bracket.save
  end
  all_teams_versus[index][:current_bracket] = bracket.current_bracket
end

all_teams_versus.each do |versus|
  Playoffs::ProcessGame.call(versus[:game], versus[:game_details].merge({"GameModeId" => playoff.uid, "CurrentBracket" => versus[:current_bracket]}))
end
