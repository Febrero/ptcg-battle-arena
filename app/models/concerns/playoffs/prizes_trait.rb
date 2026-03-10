module Playoffs
  module PrizesTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def get_prize_by_rounds_completed_and_number_of_players_in_round(rounds_completed, number_of_players_in_round)
      prize_amount = 0.0
      prize_config_value = prize_config_per_round[rounds_completed][:percentage_or_unit]
      if prize_config_per_round[rounds_completed][:type_prize_distribution] == :prize_percentage
        percentage = (prize_config_value / 100.0) / number_of_players_in_round

        # prize amount
        prize_amount = prize_pool_winner_share * percentage
      else
        prize_amount = prize_config_value
      end
      prize_amount
    end

    def get_prizes
      # if all prizes already processed we should persist more time if not  maybe less time

      Rails.cache.fetch("Playoffs::#{uid}::Prizes", expires_in: 5.minutes) do
        prize_config = prize_config_per_round
        prizes = []
        page = 1
        loop do
          json = InternalApi
            .new
            .get("prizes", request_uri: "/prizes?filter[state]=processed&filter[game_mode_id]=#{uid}&filter[page]=#{page}&filter[per_page]=100")
            .json(true)

          json[:data].each do |row|
            prize = row[:attributes]
            prize_amount = 0.0
            if prize[:prize_awarded]
              prize_config_value = prize_config[prize[:playoff_rounds_completed].to_i][:percentage_or_unit]
              if prize_config[:type_prize_distribution] == :prize_percentage
                percentage = (prize_config_value / 100.0) / prize[:playoff_number_of_players_in_round]
                prize_amount = prize_pool_winner_share * percentage
              else
                prize_amount = prize_config_value
              end

            end

            prizes << {wallet_addr: row[:attributes][:wallet_addr], prize: prize_amount, rounds_completed: prize[:playoff_rounds_completed].to_i}
          end

          break if page >= json[:meta][:total_pages]

          page += 1
        end

        prizes.sort_by! { |prize| -prize[:rounds_completed] }
      end
    end

    def prize_amount_by_round(round_completed)
      get_prizes_by_rounds_completed[round_completed] ||
        {amount: 0.0, type: (erc20_name_alt || erc20_name)}
    end

    def get_prizes_by_rounds_completed
      prize_distribution.each_with_object({}) do |item, hash|
        key = item[:rounds_completed]
        value = {amount: item[:prize], type: item[:type]}
        hash[key] = value
      end
    end

    # This method is used to calculate the prize distribution for the playoff, if you give an prize pool we will calculate the prize distribution based on that prize pool
    def prize_distribution(from_prize_pool = nil)
      n_teams = teams.count
      prize_pool = prize_pool_winner_share

      if n_teams < min_teams
        if !has_custom_prize
          ticket = Ticket.where(bc_ticket_id: compatible_ticket_ids.first.to_i, ticket_factory_contract_address: ticket_factory_contract_address).first
          prize_pool = ((ticket.base_price * (ticket_amount_needed.presence || 1)) * min_teams) * winner_share
        end
        n_teams = min_teams
      end

      prize_pool = from_prize_pool if from_prize_pool.present?

      PlayoffsUtils.prize_distribution(total_rounds(n_teams), prize_config_per_round(n_teams), prize_pool, erc20_name_alt || erc20_name)
    end

    def prize_distribution_custom(prize_pool, n_teams, erc20_name_alt = "USDT")
      PlayoffsUtils.prize_distribution(total_rounds(n_teams), prize_config_per_round(n_teams), prize_pool, erc20_name_alt)
    end

    def prize_distribution_grid(max_teams = ::Playoff::TOTAL_TEAMS_FORMAT.max)
      Mongoid.logger.level = :error

      (4..max_teams).each do |n_teams|
        ticket = Ticket.where(bc_ticket_id: compatible_ticket_ids.first.to_i, ticket_factory_contract_address: ticket_factory_contract_address).first
        prize_pool = ((ticket.base_price * (ticket_amount_needed.presence || 1)) * n_teams)
        prize_pool_net = prize_pool * winner_share
        prize_rf_share = prize_pool * rf_share
        prize_rf_burn = prize_pool * burn_share
        _, _, tie_break = prize_slots_to_apply(n_teams)
        dist = PlayoffsUtils.prize_distribution(total_rounds(n_teams), prize_config_per_round(n_teams), prize_pool_net, erc20_name_alt || erc20_name)

        conf = {
          n_teams: n_teams,
          ticket_price: ticket.base_price,
          total_rounds: total_rounds(n_teams),
          gross_prize: prize_pool,
          net_prize: prize_pool_net,
          rf_share: prize_rf_share,
          to_burn: prize_rf_burn,
          tie_break: "#{tie_break}%",
          rounds_percentage: prize_config_per_round(n_teams),
          distribution: dist
        }
        data = JSON.parse(conf.to_json)
        puts "## NTEAMS #{n_teams} ##"
        puts JSON.pretty_generate(data)
      end
    end

    def prize_slots_to_apply(n_teams = nil)
      teams_count = n_teams || teams.count
      tournament_format = Playoff::TOTAL_TEAMS_FORMAT
      tournament_teams_slots = tournament_format.detect { |b| b >= teams_count }
      bye_slots = tournament_teams_slots - teams_count

      index = tournament_format.index(tournament_teams_slots)
      slot_prize = tournament_format[index]
      tie_break = 100.0
      increment_rounds_config = false
      if bye_slots > 0
        slot_prize_previous = tournament_format[index - 1]
        diff = slot_prize - slot_prize_previous

        tie_break = ((teams_count - slot_prize_previous) * 100.0 / diff.to_f)
        slot_prize = if tie_break >= ::Playoff::TIEBREAKER_PERCENTAGE_PRIZE_SLOT
          tournament_format[index]
        else
          increment_rounds_config = true
          tournament_format[index - 1]
        end
      end

      [slot_prize, increment_rounds_config, tie_break]
    end

    def prize_config_apply(n_teams = nil)
      slot_prize, increment_rounds_config, _ = prize_slots_to_apply(n_teams)
      prize_config_to_apply = prize_config&.config&.[](slot_prize.to_s)

      if increment_rounds_config
        prize_config_to_apply = prize_config_to_apply.map { |hash| hash.merge("rounds_completed" => hash["rounds_completed"] + 1) }
      end
      prize_config_to_apply
    end

    def prize_config_per_round_percentage(n_teams = nil)
      rounds_percentage = {}
      prize_config_apply(n_teams).each do |config|
        rounds_percentage[config[:rounds_completed]] = config[:prize_percentage]
      end
      rounds_percentage
    end

    def prize_config_per_round(n_teams = nil)
      rounds_percentage = {}
      prize_config_apply(n_teams).each do |config|
        rounds_percentage[config[:rounds_completed]] = {
          percentage_or_unit: config[:prize_percentage] || config[:prize_unit],
          type_prize_distribution: config[:prize_percentage] ? :prize_percentage : :prize_unit,
          details: config[:details]
        }
      end
      rounds_percentage
    end
  end
end
