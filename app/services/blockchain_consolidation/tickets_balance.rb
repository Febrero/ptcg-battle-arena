module BlockchainConsolidation
  class TicketsBalance < ApplicationService
    attr_reader :wallet_addr, :game_mode, :tf_contract_address, :tld_contract_address, :ticket_id

    def call(wallet_addr, game_mode, tf_contract_address, tld_contract_address, ticket_id)
      @wallet_addr = wallet_addr
      @game_mode = game_mode
      @tf_contract_address = tf_contract_address
      @tld_contract_address = tld_contract_address
      @ticket_id = ticket_id

      {
        balance: wallet_balance,
        locked: total_locked - tickets_spent,
        total_locked: total_locked,
        total_spent: tickets_spent
      }
    end

    def wallet_balance
      client.call(ticket_factory, "balanceOf", checksummed_wallet_addr, ticket_id)
    end

    def total_locked
      client.call(ticket_locker_and_distribution, "totalTicketsDeposited", checksummed_wallet_addr, ticket_id)
    end

    def tickets_spent
      case game_mode
      when "Arena"
        GamePlayer.where(wallet_addr: checksummed_wallet_addr, ticket_id: ticket_id).count

      when "Survival"
        count = 0
        SurvivalPlayer.where(wallet_addr: checksummed_wallet_addr).each do |sp|
          count += sp.entries.where(ticket_id: ticket_id).count
        end

        count
      end
    end

    def checksummed_wallet_addr
      Eth::Address.new(wallet_addr.downcase).checksummed
    end

    def client
      @client ||= Eth::Client.create(Rails.application.config.rpc_endpoint)
    end

    def ticket_factory
      @ticket_factory ||= Eth::Contract.from_abi(
        address: Eth::Address.new(tf_contract_address.downcase),
        abi: ticket_factory_abi,
        name: "TicketFactory"
      )
    end

    def ticket_locker_and_distribution
      @ticket_locker_and_distribution ||= Eth::Contract.from_abi(
        address: Eth::Address.new(tld_contract_address.downcase),
        abi: ticket_locker_and_distribution_abi,
        name: "TicketLockerAndDistribution"
      )
    end

    def ticket_factory_abi
      JSON.parse(File.read("abis/ticket_factory.json"))
    end

    def ticket_locker_and_distribution_abi
      JSON.parse(File.read("abis/ticket_locker_and_distribution.json"))
    end
  end
end
