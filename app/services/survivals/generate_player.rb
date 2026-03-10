module Survivals
  class GeneratePlayer < ApplicationService
    def call wallet_addr, survival_uid, ticket_id
      Rails.logger.info "Generating survival player\n\twallet_addr: #{wallet_addr}\n\tsurvival: #{survival_uid}"

      raise Survivals::PlayerFieldsMissing if wallet_addr.blank? ||
        survival_uid.blank? ||
        ticket_id.blank?

      survival = Survival.find_by(uid: survival_uid)
      survival_player = SurvivalPlayer.where(wallet_addr: wallet_addr, survival_id: survival.uid).first_or_create

      survival_player.begin_streak(ticket_id)

      tickets_charged = SpendTickets.call(
        players: [{
          bc_ticket_id: ticket_id,
          wallet_addr: survival_player.wallet_addr,
          ticket_factory_contract_address: survival.ticket_factory_contract_address
        }],
        entry_id: survival_player.active_entry_id,
        entry_type: "Survival",
        game_mode_id: survival.uid
      )

      if !tickets_charged
        survival_player.active_entry.destroy

        raise Survivals::TicketNotSpent
      end

      survival_player
    end
  end
end
