module V1
  class TicketBalancesController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::TicketBalancesControllerDoc

    prepend_before_action :authenticate_user!, only: [:user]
    before_action :auth_frontend, only: [:user]
    before_action :auth_external_api, only: [:spend]
    around_action :use_read_only_databases, only: [:user]

    api :GET, "/ticket_balances/user", "User tickets balances (Authenticaded)"
    param_group :ticket_balances_controller_user, Docs::V1::TicketBalancesControllerDoc
    def user
      render json: UserTicketBalances.call(@user_data["publicAddress"]),
        each_serializer: TicketBalanceSerializer,
        adapter: :json_api,
        status: :ok
    end

    api :PUT, "/ticket_balances/spend", "Spend a ticket"
    param_group :ticket_balances_controller_spend, Docs::V1::TicketBalancesControllerDoc
    def spend
      render json: {success: SpendTickets.call(ticket_balance_params)}, status: :ok
    end

    # private

    def ticket_balance_params
      params.permit(:game_id, :game_mode_id, players: [:bc_ticket_id, :wallet_addr, :ticket_factory_contract_address])
    end
  end
end
