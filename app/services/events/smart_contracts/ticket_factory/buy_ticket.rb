module Events
  module SmartContracts
    module TicketFactory
      class BuyTicket < ApplicationService
        def call(event)
          MongoidTransaction.perform(EventTransaction) do
            if Events::SmartContracts::ValidateTransaction.call(event)
              Rails.logger.info("Event #{event}")
              contract_address = event["contract_address"]
              ticket = Ticket.where(bc_ticket_id: event["ticket_id"], ticket_factory_contract_address: contract_address).first
              @ticket_balance = TicketBalance.find_or_create_by(
                wallet_addr: event["buyer"],
                ticket: ticket
              )

              event["removed"] ? revert(event) : execute(event)

              begin
                update_reward_campaign(event["buyer"], event["quantity"].to_i)
              rescue => e
                Airbrake.notify(e)
              end
            end
          end
        end

        private

        def execute(event)
          @ticket_balance.balance += event["quantity"].to_i
          @ticket_balance.save
        end

        def update_reward_campaign(buyer, quantity)
          wallet_addr = Web3::Address.new(buyer).checksummed
          reward_campaign = Rewards::RewardCampaign.find(wallet_addr).first

          Rails.logger.info "Purchase action when the user buys a Ticket from the wallet: #{wallet_addr} and we update the Reward Campaign"

          reward_campaign&.update_attributes({wallet_addr: wallet_addr, action_marketplace: "buy_fba_ticket", action_made_count: quantity})
        rescue JsonApiClient::Errors::NotFound
          raise RequestNotFound
        rescue JsonApiClient::Errors::RequestTimeout
          raise ServiceConnectionTimeout
        rescue JsonApiClient::Errors::AccessDenied
          raise ServiceConnectionForbidden
        rescue => e
          Airbrake.notify(e)
        end

        def revert(event)
          @ticket_balance.balance -= event["quantity"].to_i
          @ticket_balance.save
        end
      end
    end
  end
end
