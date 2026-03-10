module V1
  class TicketBalanceSerializer < ActiveModel::Serializer
    attributes :wallet_addr,
      :balance,
      :deposited,
      :bc_ticket_id,
      :ticket_factory_contract_address,
      :ticket_locker_and_distribution_contract_address
  end
end
