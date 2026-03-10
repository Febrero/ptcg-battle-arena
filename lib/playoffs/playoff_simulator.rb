class PlayoffSimulator
  GameClass = Struct.new(:game_id, :game_mode_id, :winner, :game_end_reason)
  attr_accessor :playoff, :teams, :n_teams, :ticket

  def initialize(n_teams, drop_all = false)
    @teams = []
    @n_teams = n_teams
    if drop_all
      Playoff.delete_all
      Playoffs::Team.delete_all
      Playoffs::Bracket.delete_all
      Playoffs::PrizeConfig.delete_all
      Ticket.delete_all
    end
    create_season
  end

  def create_season
    if !Season.currently_active.first
      Season.create(name: "Season-1", active: true, start_date: Time.now, end_date: Time.now + 1.year)
    end
  end

  def red(msg)
    puts "\033[31m#{msg}\033[0m"
  end

  def green(msg)
    puts "\033[32m#{msg}\033[0m"
  end

  def create_prize_config
    Playoffs::PrizeConfig
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
          ],
          64 => [
            {
              rounds_completed: 6,
              prize_percentage: 40
            },
            {
              rounds_completed: 5,
              prize_percentage: 25
            },
            {
              rounds_completed: 4,
              prize_percentage: 20
            },
            {
              rounds_completed: 3,
              prize_percentage: 15
            }
          ],
          128 => [
            {
              rounds_completed: 7,
              prize_percentage: 32.5
            },
            {
              rounds_completed: 6,
              prize_percentage: 20
            },
            {
              rounds_completed: 5,
              prize_percentage: 17.5
            },
            {
              rounds_completed: 4,
              prize_percentage: 15
            },
            {
              rounds_completed: 3,
              prize_percentage: 15
            }
          ],
          256 => [
            {
              rounds_completed: 8,
              prize_percentage: 27.5
            },
            {
              rounds_completed: 7,
              prize_percentage: 17.5
            },
            {
              rounds_completed: 6,
              prize_percentage: 15
            },
            {
              rounds_completed: 5,
              prize_percentage: 15
            },
            {
              rounds_completed: 4,
              prize_percentage: 12.5
            },
            {
              rounds_completed: 3,
              prize_percentage: 12.5
            }
          ],
          512 => [
            {
              rounds_completed: 9,
              prize_percentage: 25
            },
            {
              rounds_completed: 8,
              prize_percentage: 15
            },
            {
              rounds_completed: 7,
              prize_percentage: 14
            },
            {
              rounds_completed: 6,
              prize_percentage: 14
            },
            {
              rounds_completed: 5,
              prize_percentage: 13
            },
            {
              rounds_completed: 4,
              prize_percentage: 12
            },
            {
              rounds_completed: 3,
              prize_percentage: 10
            }
          ],
          1024 => [
            {
              rounds_completed: 10,
              prize_percentage: 23
            },
            {
              rounds_completed: 9,
              prize_percentage: 14.5
            },
            {
              rounds_completed: 8,
              prize_percentage: 13
            },
            {
              rounds_completed: 7,
              prize_percentage: 12
            },
            {
              rounds_completed: 6,
              prize_percentage: 11
            },
            {
              rounds_completed: 4,
              prize_percentage: 10
            },
            {
              rounds_completed: 3,
              prize_percentage: 9
            }
          ],
          2048 => [
            {
              rounds_completed: 12,
              prize_percentage: 21
            },
            {
              rounds_completed: 11,
              prize_percentage: 13
            },
            {
              rounds_completed: 10,
              prize_percentage: 12
            },
            {
              rounds_completed: 9,
              prize_percentage: 11
            },
            {
              rounds_completed: 8,
              prize_percentage: 10
            },
            {
              rounds_completed: 7,
              prize_percentage: 9
            },
            {
              rounds_completed: 6,
              prize_percentage: 8.5
            }
          ],
          4096 => [
            {
              rounds_completed: 13,
              prize_percentage: 18.1
            },
            {
              rounds_completed: 12,
              prize_percentage: 10.7
            },
            {
              rounds_completed: 11,
              prize_percentage: 10.3
            },
            {
              rounds_completed: 10,
              prize_percentage: 9.9
            },
            {
              rounds_completed: 9,
              prize_percentage: 9.5
            },
            {
              rounds_completed: 8,
              prize_percentage: 9.1
            },
            {
              rounds_completed: 7,
              prize_percentage: 8.7
            }
          ]
        }
      )
  end

  def create_prize_config_tickets
    Playoffs::PrizeConfig
      .create(
        active: true,
        name: "Prize Config",
        config:
        {
          2 => [{
            rounds_completed: 1,
            prize_unit: 2,
            details: {}
          }],
          4 => [
            {
              rounds_completed: 2,
              prize_unit: 2,
              details: {
                "bc_ticket_id" => ["1"],
                "ticket_factory_contract_address" => "0x0ceF6939f9eB08264b0ed69D9B1A0DcE256e6332"
              }
            }
          ]
        }
      )
  end

  def create_playoff
    ticket_factory_contract_address = "0x0ceF6939f9eB08264b0ed69D9B1A0DcE256e6332"
    ticket_locker_and_distribution_contract_address = "0xE67Faf005A6DcF79F43d5cf1eb8B9B59426aE995"
    ticket_id = "1"
    # erc20 = "0xe3C7bB689e975735bcF8e2bae1e249dc65554AC3"

    @ticket = create_ticket(ticket_id, ticket_factory_contract_address, ticket_locker_and_distribution_contract_address)

    p_info = {
      state: "upcoming",
      name: "Playoff Simulator",
      active: true,
      open_date: (Time.now + 1.minutes),
      open_timeframe: 1,
      pregame_timeframe: 1,
      default_round_duration: 1,
      min_deck_tier: 1,
      max_deck_tier: 1,
      min_teams: @n_teams,
      max_teams: @n_teams,
      total_prize_pool: 10000.0,
      prize_pool_winner_share: 5000.0,
      prize_pool_realfevr_share: 5000.0,
      compatible_ticket_ids: [ticket_id],
      erc20_name: "FEVR",
      ticket_factory_contract_address: ticket_factory_contract_address,
      ticket_locker_and_distribution_contract_address: ticket_locker_and_distribution_contract_address,
      prize_config: create_prize_config,
      rf_percentage: 4,
      burn_percentage: 1,
      spend_ticket: false
    }
    @playoff = Playoff.create!(p_info)
    self
  end

  def create_ticket(ticket_id, ticket_factory_contract_address, ticket_locker_and_distribution_contract_address)
    ticket = Ticket.where(bc_ticket_id: ticket_id.to_i, ticket_factory_contract_address: ticket_factory_contract_address, game_mode: "playoff").first_or_create do |t|
      t.name = "ticket playoff"
      t.description = "ticket playoff"
      t.base_price = 20_000
      t.expiration_date = Time.now + 10.years
      t.sale_expiration_date = Time.now + 10.years
      t.available_quantities = ["1", "2", "3", "4", "5", "10"]
      t.ticket_locker_and_distribution_contract_address = ticket_locker_and_distribution_contract_address
    end
    ticket.save!
    ticket
  end

  def open
    if playoff_reload.open!
      Playoffs::Notificator.call(playoff_reload.uid, Playoffs::Notificator::TYPE_STATE)
    end
  end

  def playoff_reload
    @playoff = playoff.reload
  end

  def spend_tickets(wallet_addr)
    Tickets::SpendTicketsPlayoff.call(playoff.uid, 1, wallet_addr, false)
  end

  def create_teams
    (1..n_teams).each do |number|
      # if spend_tickets("0xB1E122C8C0AA8314091F29Ac6445fcecD0672019")
      #   add_team_to_playoff
      # end
      add_team_to_playoff(number)
      ::Playoffs::CalculatePrizePool.new(playoff.reload).call!
    end
  end

  def wait_until_open
    n_minutes = 2
    puts "Waiting to open playoff (#{playoff_reload.open_date})"
    sleep_interval = 10 # second
    is_open = false
    cycles = 1
    until is_open
      print "."
      is_open = playoff_reload.opened?
      sleep sleep_interval if !is_open
      break if (cycles * sleep_interval) > (n_minutes * 60) + 40
      cycles += 1
    end
    puts ""
    if is_open
      green("Playoff is Open #{Time.now.utc}")
    else
      red("Playoff is NOT OPEN")
      raise "PLAYOFF DIDNT CHANGE STATE TO OPEN (#{playoff_reload.state}})"
    end
  end

  def wait_until_warmup
    n_minutes = playoff_reload.open_timeframe
    puts "Waiting to warmup playoff #{n_minutes} minutes"
    sleep_interval = 10 # second
    yield
    is_warmup = false
    cycles = 1
    until is_warmup
      print "."
      is_warmup = playoff_reload.warmup?
      sleep sleep_interval if !is_warmup
      break if (cycles * sleep_interval) > (n_minutes * 60) + 40
      cycles += 1
    end
    puts ""
    if is_warmup
      green("Playoff is Warmup")
    else
      red("Playoff is NOT Warmup")
      raise "PLAYOFF DIDNT CHANGE STATE TO WARMUP (#{playoff_reload.state}})"
    end
  end

  def wait_until_start
    n_minutes = playoff_reload.pregame_timeframe
    puts "Waiting to start playoff #{n_minutes} minutes"
    sleep_interval = 10 # second
    is_ongoing = false
    cycles = 1
    until is_ongoing
      print "."
      is_ongoing = playoff_reload.ongoing?
      sleep sleep_interval if !is_ongoing
      break if (cycles * sleep_interval) > (n_minutes * 60) + 40
      cycles += 1
    end
    puts ""
    if is_ongoing
      green("Playoff is ongoing")
    else
      red("Playoff is NOT Ongoing")
      raise "PLAYOFF DIDNT CHANGE STATE TO Ongoing (#{playoff_reload.state}})"
    end
  end

  def wait_all_brackets_exists
    brackets_created = false
    puts "Checking if all brackets are done"
    until brackets_created
      print "."
      brackets_created = all_brackets_are_ready
      sleep 2 unless brackets_created
    end
    green("All Brackets Are READY")
  end

  def all_brackets_are_ready
    # we know that process of creation goes from top to bottom
    # so if all teams are ready in round 1 we can infered that
    # all brackets are done

    total_teams_in_brackets_first_round = 0
    playoff_reload.brackets.where(round: 1).to_a.each do |bracket|
      total_teams_in_brackets_first_round += bracket.teams_ids.compact.count
    end
    (total_teams_in_brackets_first_round == playoff.teams.count)
  end

  def buy_ticket(quantity = 1)
    # data: JSON.generate({playoff_uid: @playoff.uid}).unpack1("H*")
    response = HTTParty.post("http://localhost:5000/buy-ticket", {
      headers: {"Content-Type" => "application/json"},
      body: {
        ticketId: @playoff.compatible_ticket_ids.first,
        quantity: quantity
      }.to_json
    })

    if response.code == 200
      puts "Ticket purchased successfully"
    else
      puts "An error occurred while buying the ticket: #{response.code}"
    end
  end

  def lock_ticket(quantity = 1)
    response = HTTParty.post("http://localhost:5000/lock-ticket", {
      headers: {"Content-Type" => "application/json"},
      body: {
        ticketId: @playoff.compatible_ticket_ids.first,
        quantity: quantity
      }.to_json
    })

    if response.code == 200
      puts "Ticket purchased successfully"
    else
      puts "An error occurred while buying the ticket: #{response.code}"
    end
  end

  def buy_and_lock_ticket(quantity = 1)
    buy_ticket(quantity)
    lock_ticket(quantity)
  end

  def check_brackets
    @playoff = playoff.reload!
    playoff.brackets
  end

  def add_team_to_playoff(number, wallet_addr = nil)
    wallet_addr ||= "0x#{SecureRandom.hex(16)}"
    team = Playoffs::Team.create(playoff: playoff, wallet_addr: wallet_addr, name: "#Team-#{number}", ticket_id: ticket.bc_ticket_id.to_s)
    if team.persisted?
      Playoffs::Notificator
        .call(
          team.playoff.uid,
          Playoffs::Notificator::TYPE_JOIN_TEAM,
          {
            team_id: team.id.to_s,
            wallet_addr: team.wallet_addr,
            wallet_addr_downcased: team.wallet_addr_downcased
          }
        )
    end
    team
  end

  def add_team_outside_open_state
    print "Trying to put one Team playoff with state: "
    print "#{playoff_reload.state}\n"

    playoff_team = add_team_to_playoff(-1)
    if playoff_team.persisted?
      red("[WRONG] we shouldnt allow add teams after open period")
      raise "WE ARE ALLOWING PUT TEAMS TO AN PLAYOFF ONGOING"
    else
      # pp playoff_team.errors
      green("[OK] we dont add new teams in a different state of open ")
    end
  end

  def wait_until_current_round_be(round)
    puts "Checking if current round is  #{round}"
    n_minutes, is_expected_current_round, sleep_interval, cycles = 2, false, 5, 1

    until is_expected_current_round
      print "."
      is_expected_current_round = playoff_reload.current_round == round
      sleep sleep_interval if !is_expected_current_round
      break if (cycles * sleep_interval) > (n_minutes * 60)
      cycles += 1
    end
    puts ""
    if is_expected_current_round
      green("Playoff is in expected round - #{round}")
    else
      red("Playoff is NOT Changing round")
      raise "PLAYOFF NOT CHANGE THE ROUND"
    end
  end

  def simulate_games(process_games = true)
    puts "SIMULATE GAMES IN BRACKETS"
    n_teams = playoff_reload.teams.count
    playoff_rounds = playoff_reload.rounds.count

    (1..playoff_rounds).each do |round|
      wait_until_current_round_be(round)
      puts "ROUND #{round} CURRENT ROUND #{playoff_reload.current_round}"
      next if !process_games
      all_brackets_played_in_round = false
      first_game = true
      until all_brackets_played_in_round
        bracket = pick_first_bracket_not_played(round)
        if bracket
          game, game_details = game_game_details(bracket)
          Playoffs::ProcessGame.call(game, game_details)
          if first_game && round == 1 && pending_brackets_in_round(round)
            green("OK first game dont change round") if current_round == round
          end
          first_game = false
        else
          all_brackets_played_in_round = true
        end

        sleep(playoff.default_round_duration / n_teams.to_f)
      end
    end
  end

  def check_brackets_without_opponent
    # Query for brackets in round 1
    round_1_brackets = playoff_reload.brackets.where(round: 1)

    # Check if any bracket has a nil team_id or missing winner
    brackets_without_winner = round_1_brackets.count { |bracket| bracket.teams_ids.include?(nil) && !bracket.winner_team_id.present? }

    brackets_without_winner == 0
  end

  def wait_all_brackets_without_opponent_be_ready
    be_ready = false
    puts "Checking if all brackets without opponent"
    until be_ready
      print "."
      be_ready = check_brackets_without_opponent
      sleep 2 unless be_ready
    end
    green("All Brackets WITHOUT opponent are ready")
  end

  def buy_lock_tickets
    (1..n_teams).each do |number|
      buy_and_lock_ticket
    end
    self
  end

  def wait(seconds)
    sleep(seconds)
    self
  end

  def check_ticket_balance
    ticket_balance = TicketBalance.where(
      bc_ticket_id: ticket.bc_ticket_id.to_i,
      wallet_addr: "0xB1E122C8C0AA8314091F29Ac6445fcecD0672019",
      ticket_factory_contract_address: playoff.ticket_factory_contract_address
    ).first

    puts "TICKET BALANCE"
    pp ticket_balance
    self
  end

  def simulate(generate_playoff = true)
    create_playoff if generate_playoff
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO
    add_team_outside_open_state
    wait_until_open

    wait_until_warmup do
      create_teams
    end

    add_team_outside_open_state
    wait_all_brackets_exists

    wait_all_brackets_without_opponent_be_ready

    wait_until_start

    simulate_games

    if playoff_reload.finished?
      green("Playoff in Finish state")
    else
      red("[WRONG] Playoff not Finish #{playoff_reload.state}")
    end

    if playoff.winner_team_id
      green("[OK] Playoff has the winner team_id")
    else
      red("[WRONG] Playoff Not finished")
    end
  rescue => exception
    pp exception
    puts exception.backtrace.join("\n")
  end

  def pick_first_bracket_not_played(round)
    playoff_reload.brackets.where(round: round, winner_team_id: nil).first
  end

  def pending_brackets_in_round(round)
    playoff_reload.brackets.where(round: round, winner_team_id: nil).count > 0
  end

  def current_round
    playoff_reload.current_round
  end

  def game_game_details(bracket)
    teams = bracket.teams
    puts "team #{teams[0]&.wallet_addr} vs #{teams[1]&.wallet_addr}"
    winner_team = teams[0]
    puts "winner #{winner_team.wallet_addr}"
    # we will put normal wallet to check that every this is ok and test downcase also
    game = GameClass.new(SecureRandom.uuid, bracket.playoff.uid, winner_team.wallet_addr, "normal")
    game_details = {
      "CurrentBracketId" => bracket.id.to_s,
      "Players" => [
        {
          "WalletAddr" => winner_team.wallet_addr,
          "GoalsScored" => 2
        },
        {
          "WalletAddr" => teams[1].wallet_addr,
          "GoalsScored" => 1
        }
      ]
    }

    [game, game_details]
  end
end
