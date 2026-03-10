module PlayoffsUtils
  module_function

  def prize_distribution(number_of_rounds, prize_config_per_round, total_prize_pool, erc20_name)
    @erc20_name = erc20_name
    prize_config = prize_config_per_round
    number_of_all_teams = 2**number_of_rounds
    prizes = []
    actual_ranking = 1

    number_of_rounds.downto(1).each do |round|
      number_of_teams_per_round = number_of_all_teams / (2**(round - 1))

      if number_of_rounds == round
        prize_amount = calc_prize_amount(prize_config[round], total_prize_pool, 1)
        prizes << object_prize(actual_ranking, actual_ranking, prize_amount, round, erc20_name)

        if prize_config[round - 1]
          prize_amount = calc_prize_amount(prize_config[round - 1], total_prize_pool, 1)
          actual_ranking += 1
          prizes << object_prize(actual_ranking, actual_ranking, prize_amount, round - 1, erc20_name)
        end
        next
      end

      next unless prize_config[round - 1]

      prize_amount = calc_prize_amount(prize_config[round - 1], total_prize_pool, (number_of_teams_per_round / 2))
      prizes << object_prize(actual_ranking + 1, actual_ranking + (number_of_teams_per_round / 2), prize_amount, round - 1, erc20_name)
      actual_ranking += (number_of_teams_per_round / 2)
    end

    prizes
  end

  def calc_prize_amount(prize_config_round, total_prize_pool, number_of_teams)
    percentage_or_unit = prize_config_round[:percentage_or_unit]

    if prize_config_round[:type_prize_distribution] == :prize_percentage
      percentage = calc_percentage(percentage_or_unit, number_of_teams)
      percentage_or_unit = total_prize_pool * percentage
    end
    percentage_or_unit
  end

  def calc_percentage(percentage_or_unit, number_of_teams)
    (percentage_or_unit / 100.0) / number_of_teams
  end

  def is_prize_percentage?
    @type_prize_distribution == :prize_percentage
  end

  def is_tickets?
    @erc20_name.downcase == "tickets"
  end

  def object_prize(ranking_start, ranking_end, prize_amount, rounds_completed, erc20_name)
    {
      ranking_start: ranking_start,
      ranking_end: ranking_end,
      prize: prize_amount.round(4),
      rounds_completed: rounds_completed,
      type: erc20_name
    }
  end
end
