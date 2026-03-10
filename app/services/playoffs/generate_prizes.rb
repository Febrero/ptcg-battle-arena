module Playoffs
  class GeneratePrizes
    include Callable

    attr_reader :playoff, :winners, :prize_config_per_round

    def initialize(playoff_uid)
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
      @prize_config_per_round = playoff.prize_config_per_round
    end

    def call
      if playoff.prizes_generated
        raise "The Prizes to playoff already was generated"
      end

      unless playoff.manual_finished? || playoff.finished?
        raise "Playoff should be in finished state"
      end

      if !playoff.automatic_prize_distribution
        raise "THE DISTRIBUTION WILL BE MADE MANUALLY, Prizes will be dispersed by the admin using some stable coin"
      end
      send_prizes
    end

    def generate_prizes
      prizes = []
      rounds_with_prize = prize_config_per_round.keys

      if playoff.finished?
        teams_rounds_completed, number_of_players_in_round = teams_rounds_completed_info
      elsif playoff.manual_finished?
        teams_rounds_completed, number_of_players_in_round = teams_rounds_incompleted_info
      else
        raise "THE PLAYOFF SHOULD BE IN FINISHED OR MANUAL FINISHED STATE"
      end

      teams_rounds_completed.each do |team_round|
        prize = prize_obj(
          team_round[:game_id],
          team_round[:wallet_addr],
          team_round[:ticket_id],
          team_round[:ticket_amount],
          team_round[:rounds_completed],
          number_of_players_in_round[team_round[:rounds_completed]],
          rounds_with_prize.include?(team_round[:rounds_completed])
        )
        prizes << prize
        yield prize
      end
      prizes
    end

    def teams_rounds_completed_info
      teams_rounds_completed = []
      total_rounds = playoff.brackets.all.max(:round)
      players_per_round = Hash.new(0)

      total_rounds.downto(1).each do |round|
        brackets = playoff.brackets.where(round: round).to_a

        # last round
        if total_rounds == round
          last_bracket = brackets.first

          ## Pay attention to this
          game_id = last_bracket.game_id || last_bracket.current_bracket

          if !last_bracket.winner_team_id
            last_bracket.teams.each do |team|
              teams_rounds_completed << obj_rounds_completed(round - 1, team, game_id)
              players_per_round[round - 1] += 1
            end
          else
            winner_team_final = playoff.teams.find(last_bracket.winner_team_id)
            teams_rounds_completed << obj_rounds_completed(round, winner_team_final, game_id)
            players_per_round[round] += 1

            second = last_bracket.teams_ids.reject { |team_id| team_id == last_bracket.winner_team_id }.first
            looser_team_final = playoff.teams.find(second)
            teams_rounds_completed << obj_rounds_completed(round - 1, looser_team_final, game_id)
            players_per_round[round - 1] += 1
          end
          next
        end

        loosers_round_teams_ids = []
        brackets.each do |bracket|
          looser = bracket.teams_ids.reject { |team_id| team_id == bracket.winner_team_id }.first
          loosers_round_teams_ids << {team_id: looser, game_id: bracket.game_id || bracket.current_bracket} if looser
        end

        loosers_round_teams_ids.each do |looser|
          looser_team = playoff.teams.find(looser[:team_id])
          teams_rounds_completed << obj_rounds_completed(round - 1, looser_team, looser[:game_id])
          players_per_round[round - 1] += 1
        end
      end
      [teams_rounds_completed, players_per_round]
    end

    def last_completed_round
      last_round_completed = nil
      playoff.total_rounds.downto(1).each do |round|
        brackets = playoff.brackets.where(round: round).to_a
        all_bracket_completed = true
        brackets.each do |bracket|
          if !bracket.winner_team_id
            all_bracket_completed = false
            break
          end
        end

        if all_bracket_completed
          last_round_completed = round
          break
        end
      end
      last_round_completed
    end

    def teams_rounds_incompleted_info
      prize_config_per_round = playoff.prize_config_per_round
      rounds_with_prize = prize_config_per_round.keys
      max_round_with_prize = rounds_with_prize.first

      teams_rounds_completed = []
      total_rounds = last_completed_round

      round_difference = max_round_with_prize - total_rounds

      players_per_round = Hash.new(0)

      total_rounds.downto(1).each do |round|
        brackets = playoff.brackets.where(round: round).to_a

        loosers_round_teams_ids = []
        brackets.each do |bracket|
          looser = bracket.teams_ids.reject { |team_id| team_id == bracket.winner_team_id }.first
          loosers_round_teams_ids << {team_id: looser, game_id: bracket.game_id || bracket.current_bracket} if looser
        end

        loosers_round_teams_ids.each do |looser|
          looser_team = playoff.teams.find(looser[:team_id])
          teams_rounds_completed << obj_rounds_completed(round + round_difference, looser_team, looser[:game_id])
          players_per_round[round + round_difference] += 1
        end
      end

      [teams_rounds_completed, players_per_round]
    end

    def obj_rounds_completed(rounds_completed, team, game_id)
      {
        rounds_completed: rounds_completed,
        team_id: team.id.to_s,
        ticket_id: team.ticket_id,
        ticket_amount: team.ticket_amount,
        wallet_addr: team.wallet_addr,
        game_id: game_id
      }
    end

    def send_prizes
      erc20_name = (playoff.erc20_name_alt || playoff.erc20_name)&.downcase

      generated_prizes = generate_prizes do |prize|
        if ["eth", "usdt", "fevr", "bnb", "eth-special"].include?(erc20_name)
          Rabbitmq::PrizesPublisher.send(prize)
        end

        if erc20_name == "tickets" || erc20_name == "nfts"
          generate_reward(prize, erc20_name)
        end
      end

      @playoff.update(prizes_generated: true)
      generated_prizes
    end

    def generate_reward(prize, reward_type = "tickets")
      game = Game.where(game_id: prize[:game_id]).first
      prize_config_round = prize_config_per_round[prize[:playoff_rounds_completed]]

      return if !prize_config_round

      reward_subtype = ""

      reward_type = "ticket" if reward_type == "tickets"
      if reward_type == "nfts"
        reward_type = "nft"
        reward_subtype = prize_config_round[:details]["rarity"] || ""
      end

      reward = {
        wallet_addr: prize[:wallet_addr],
        value: prize_config_round[:percentage_or_unit],
        reward_type: reward_type,
        source: "battle_arena",
        game_id: prize[:game_id],
        arena: playoff.uid,
        game_mode: playoff._type,
        game_mode_id: playoff.uid,
        season: game&.season || Season.currently_active.first&.uid,
        event_detail: {
          round_completed: prize[:playoff_rounds_completed],
          number_of_players_in_round: prize[:playoff_number_of_players_in_round]
        },
        event_type: "Playoff",
        reward_subtype: reward_subtype,
        offer_detail: prize_config_round[:details],
        is_correction_event: false
      }

      reward = Rewards::Reward.create reward

      claim_reward(reward)
    end

    def claim_reward reward
      return if reward.state == "delivered"

      reward.state_event = "claim"
      reward.save
    end

    def prize_obj(game_id, wallet_addr, ticket_id, ticket_amount, rounds_completed, n_players_in_round, prize_awarded)
      {
        game_id: "#{game_id}-#{rounds_completed}",
        ticket_id: ticket_id,
        ticket_amount: ticket_amount,
        erc20: playoff.token["address"],
        erc20_name: playoff.erc20_name_alt || playoff.erc20_name,
        match_type: "Playoff",
        game_mode: "Playoff",
        game_mode_id: playoff.uid,
        playoff_rounds_completed: rounds_completed,
        playoff_number_of_players_in_round: n_players_in_round,
        # wallet_addr: "0xB1E122C8C0AA8314091F29Ac6445fcecD0672019",
        wallet_addr: wallet_addr,
        prize_awarded: prize_awarded
      }
    end
  end
end
