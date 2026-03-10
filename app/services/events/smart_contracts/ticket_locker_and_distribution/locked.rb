module Events
  module SmartContracts
    module TicketLockerAndDistribution
      class Locked < ApplicationService
        def call(event)
          MongoidTransaction.perform(EventTransaction) do
            if Events::SmartContracts::ValidateTransaction.call(event)
              ticket = Ticket.find_by(
                bc_ticket_id: event["ticket_id"],
                ticket_locker_and_distribution_contract_address: event["contract_address"]
              )

              @ticket_balance = TicketBalance.find_by(
                wallet_addr: event["owner"],
                ticket: ticket
              )
              event["removed"] ? revert(event) : execute(event)
            end
          end
        end

        private

        def execute(event)
          @ticket_balance.balance -= event["amount"].to_i
          @ticket_balance.deposited += event["amount"].to_i
          @ticket_balance.save
        end

        def revert(event)
          @ticket_balance.balance += event["amount"].to_i
          @ticket_balance.deposited -= event["amount"].to_i
          @ticket_balance.save
        end
      end
    end
  end
end
