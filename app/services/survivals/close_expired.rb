module Survivals
  class CloseExpired < ApplicationService
    def call
      Rails.logger.info "Going to close expired survivals"

      Survival.active.lt(end_date: Time.now.utc).each do |survival|
        survival.close!
        return_tickets_to_players_without_games(survival)
        base_query = SurvivalPlayer.where(survival_id: survival.uid).ne(active_entry_id: nil)
        total_survival_players = base_query.count
        enqueued_survival_players_count = 0
        batch_size = 100

        while total_survival_players > enqueued_survival_players_count
          sp_ids = base_query.offset(enqueued_survival_players_count).limit(batch_size).map { |sp| sp.id.to_s }

          Survivals::FinishPlayersStreaksJob.perform_in(30.minutes, sp_ids)

          enqueued_survival_players_count += batch_size
        end
      end
    end

    def return_tickets_to_players_without_games(survival)
      survival.survival_players.where(games_on_survival: []).each do |survival_player|
        ticket_id = survival.compatible_ticket_ids.first

        ticket_balance = TicketBalance.where(
          bc_ticket_id: ticket_id.to_i,
          wallet_addr: survival_player.wallet_addr,
          ticket_factory_contract_address: survival.ticket_factory_contract_address
        ).first
        ticket_balance.deposited += survival&.ticket_amount_needed || 1
        ticket_balance.save
      end
    end
  end
end
