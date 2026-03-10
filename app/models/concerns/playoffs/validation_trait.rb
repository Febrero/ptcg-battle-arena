module Playoffs
  module ValidationTrait
    extend ActiveSupport::Concern
    # @!parse include Playoff

    def is_full_configured
      all_not_null = compatible_ticket_ids.all? do |ticket_id|
        Ticket.where(bc_ticket_id: ticket_id.to_i, ticket_factory_contract_address: ticket_factory_contract_address).exists?
      end

      prize_config && all_not_null
    end

    def max_teams_allowed
      max_teams || Playoff::TOTAL_TEAMS_FORMAT.max
    end

    def validate_max_teams
      if max_teams.present? && max_teams > Playoff::TOTAL_TEAMS_FORMAT.max
        errors.add(:max_teams, "The max teams of playoff can not be higher than #{Playoff::TOTAL_TEAMS_FORMAT.max}")
      end
      if max_teams.to_i < min_teams.to_i
        errors.add(:max_teams, "The max teams of playoff can not be lower than min teams (#{min_teams})")
      end
    end

    def validate_max_deck_tier
      if max_deck_tier.to_i < min_deck_tier.to_i
        errors.add(:max_deck_tier, "The max deck tier of playoff can not be lower than min deck tier (#{min_deck_tier})")
      end
    end

    def validate_open_date
      if open_date.present? && open_date < Time.now.utc - 3.hours
        errors.add(:open_date, "You cant configure an playoff with open date in the past ")
      end
    end

    # validate number of teams if there not enought teams we must cancel playoff and update return ticket for each player/team
    def validate_number_of_teams
      reload
      n_teams = teams.count

      if n_teams < min_teams || n_teams > max_teams_allowed
        if cancel!
          if spend_ticket
            teams&.each do |team|
              ticket_balance = TicketBalance.where(
                bc_ticket_id: team[:ticket_id].to_i,
                wallet_addr: team[:wallet_addr],
                ticket_factory_contract_address: ticket_factory_contract_address
              ).first
              ticket_balance.deposited += ticket_amount_needed
              ticket_balance.save
            end
          end

          Playoffs::Notificator.call(uid, Playoffs::Notificator::TYPE_STATE)
        end
        raise Playoffs::MinMaxPlayoffTeams.new(min_teams, max_teams_allowed, n_teams)
      end
    end
  end
end
