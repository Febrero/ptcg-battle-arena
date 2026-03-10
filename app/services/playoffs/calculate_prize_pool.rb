module Playoffs
  class CalculatePrizePool
    include Callable

    attr_reader :playoff, :save

    def initialize(playoff, save = false)
      @playoff = playoff
      @save = save
    end

    def call
      calculate_prizes
      playoff.save(validate: false) if save
    end

    private

    def calculate_prizes
      calculate_total_prize_pool
      calculate_shares
    end

    def calculate_shares
      @playoff.prize_pool_winner_share = playoff.calc_prize_pool_winner_share
      @playoff.prize_pool_realfevr_share = playoff.calc_prize_pool_realfevr_share
      @playoff.prize_pool_possible_cashback_share = playoff.calc_prize_pool_possible_cashback_share
    end

    def calculate_total_prize_pool
      n_teams = playoff.teams.count
      teams_in_tournament = (n_teams <= playoff.min_teams) ? playoff.min_teams : n_teams
      ticket = Ticket.where(bc_ticket_id: playoff.compatible_ticket_ids.first.to_i, ticket_factory_contract_address: playoff.ticket_factory_contract_address).first
      base_price = (ticket.base_price * (playoff.ticket_amount_needed.presence || 1))

      if !playoff&.has_custom_prize # normal playoff
        @playoff.total_prize_pool = base_price * teams_in_tournament
      elsif playoff.multiplier_prize.to_i > 0 # playoff custom prize and multiplier is defined
        n_teams = find_correct_slot(teams_in_tournament)
        @playoff.total_prize_pool = (base_price * n_teams) * playoff.multiplier_prize
      end

      # in has_custom_prize case we will keep the total_prize_pool that was defined
    end

    def find_correct_slot(number_of_teams, threshold_percentage = ::Playoff::THRESHOLD_MULTIPLIER_NEXT_SLOT)
      return Playoff::TOTAL_TEAMS_FORMAT.last if number_of_teams > ::Playoff::TOTAL_TEAMS_FORMAT.last

      slot = -1
      Playoff::TOTAL_TEAMS_FORMAT.each do |n_teams|
        break if n_teams > number_of_teams
        slot += 1
      end

      min_teams = Playoff::TOTAL_TEAMS_FORMAT[slot]
      next_teams = Playoff::TOTAL_TEAMS_FORMAT[(slot + 1)]

      diff_between_slots = next_teams - min_teams
      diff = number_of_teams - min_teams
      diff_percentage = (diff.to_f / diff_between_slots)

      if diff_percentage >= threshold_percentage
        min_teams = next_teams
      end

      min_teams
    end
  end
end
