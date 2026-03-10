module Events
  module SmartContracts
    module TicketFactory
      class TransferBatch < ApplicationService
        def call(event)
          MongoidTransaction.perform(EventTransaction) do
            if Events::SmartContracts::ValidateTransaction.call(event)
              Rails.logger.info("Event #{event}")

              return if is_ignorable_sender?(event["from"])
              return if is_ignorable_receiver?(event["to"])

              event["ticket_ids"].each_index do |idx|
                ticket = Ticket.where(
                  bc_ticket_id: event["ticket_ids"][idx],
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
                event["removed"] ? revert(event["values"][idx]) : execute(event["values"][idx])
              end
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

        def execute(value)
          @prev_owner_ticket_balance.balance -= value.to_i
          @prev_owner_ticket_balance.save

          @current_owner_ticket_balance.balance += value.to_i
          @current_owner_ticket_balance.save
        end

        def revert(value)
          @prev_owner_ticket_balance.balance += value.to_i
          @prev_owner_ticket_balance.save

          @current_owner_ticket_balance.balance -= value.to_i
          @current_owner_ticket_balance.save
        end
      end
    end
  end
end
