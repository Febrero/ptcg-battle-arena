module Events
  module SmartContracts
    module TicketFactory
      class TransferSingle < ApplicationService
        def call(event)
          MongoidTransaction.perform(EventTransaction) do
            if Events::SmartContracts::ValidateTransaction.call(event)
              Rails.logger.info("Event #{event}")

              return if is_ignorable_sender?(event["from"])
              return if is_ignorable_receiver?(event["to"])

              ticket = Ticket.where(
                bc_ticket_id: event["ticket_id"],
                ticket_factory_contract_address: event["contract_address"]
              ).first

              @prev_owner_ticket_balance = TicketBalance.find_or_create_by(
                wallet_addr: event["from"],
                ticket: ticket
              )
              @current_owner_ticket_balance = TicketBalance.find_or_create_by(
                wallet_addr: event["to"],
                ticket: ticket
              )

              set_ticket_offer_offered(event) if is_ticket_offer?(event)

              event["removed"] ? revert(event) : execute(event)
            end
          end
        end

        private

        def is_ignorable_sender?(address)
          [
            "0x0000000000000000000000000000000000000000",
            *Ticket.distinct(:ticket_factory_contract_address).map(&:downcase),
            *Ticket.distinct(:ticket_locker_and_distribution_contract_address).map(&:downcase)
          ].include?(address.downcase)
        end

        def is_ignorable_receiver?(address)
          Ticket.distinct(:ticket_locker_and_distribution_contract_address).map(&:downcase).include?(address.downcase)
        end

        def execute(event)
          @prev_owner_ticket_balance.balance -= event["value"].to_i
          @prev_owner_ticket_balance.save

          @current_owner_ticket_balance.balance += event["value"].to_i
          @current_owner_ticket_balance.save
        end

        def revert(event)
          @prev_owner_ticket_balance.balance += event["value"].to_i
          @prev_owner_ticket_balance.save

          @current_owner_ticket_balance.balance -= event["value"].to_i
          @current_owner_ticket_balance.save
        end

        def is_ticket_offer?(event)
          event["from"].downcase == Rails.application.config.ticket_offer_wallet_addr.downcase
        end

        def set_ticket_offer_offered(event)
          ticket = Ticket.where(bc_ticket_id: event["ticket_id"], ticket_factory_contract_address: event["contract_address"]).first
          ticket_offer = TicketOffer.where(wallet_addr: event["to"].downcase, quantity: event["value"], ticket: ticket, offered: false).first
          ticket_offer&.update(offered: true, tx_hash: event["tx_hash"], delivered_at: Time.now)
        end
      end
    end
  end
end
