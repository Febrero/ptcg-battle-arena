module BlockchainConsolidation
  class GenerateTicketTransactions < ApplicationService
    def call
      ticket_factory_contract_addresses.each do |address|
        rpc_endpoint = Rails.application.config.rpc_endpoint
        abi = JSON.parse(File.read("abis/ticket-factory.json"))

        recoverer = Blockchain::EventsRecoverer.new(rpc_endpoint, address, abi, nil, nil, 10000)

        recoverer.recover do |event|
          handle_ticket_factory_event(event)
        end
      end

      # ticket factories
      ticket_locker_and_distribution_contract_addresses.each do |address|
        rpc_endpoint = Rails.application.config.rpc_endpoint
        abi = JSON.parse(File.read("abis/ticket-locker-and-distribution.json"))

        recoverer = Blockchain::EventsRecoverer.new(rpc_endpoint, address, abi, nil, nil, 10000)

        recoverer.recover do |event|
          handle_ticket_locker_and_distribution_event(event)
        end
      end

      arenas_uids = Arena.distinct(:uid)
      Game.in(game_mode_id: arenas_uids).each do |game|
        game.players.each do |player|
          handle_spend({
            bc_ticket_id: player.ticket_id,
            ticket_factory_contract_address: game.game_mode.ticket_factory_contract_address,
            amount: player.ticket_amount,
            game_mode_id: game.game_mode_id,
            spend_id: game.game_id,
            sender: player.wallet_addr
          })
        end
      end

      SurvivalPlayer.all.each do |survival_player|
        survival_player.entries.each do |entry|
          handle_spend({
            bc_ticket_id: entry.ticket_id,
            ticket_factory_contract_address: survival_player.survival.ticket_factory_contract_address,
            amount: entry.ticket_amount,
            game_mode_id: survival_player.survival_id,
            spend_id: entry.id,
            sender: survival_player.wallet_addr
          })
        end
      end

      # verificar se o playoff foi cancelado para nao gastar esses tickets
      # Playoffs::Team.all.each do |team|
      #   handle_spend({})
      # end
    end

    def handle_ticket_factory_event(event)
      case event.last.name
      when "TransferSingle"
        handle_transfer_single(event)
      when "TransferBatch"
        handle_transfer_batch(event)
      when "BuyTicket"
        handle_buy_ticket(event)
      end
    end

    def handle_ticket_locker_and_distribution_event(event)
      case event.last.name
      when "Locked"
        handle_locked(event)
      end
    end

    def handle_transfer_single(event)
      TicketTransactions::TransferSingle.create(
        bc_ticket_id: event.last.kwargs[:id],
        ticket_factory_contract_address: Eth::Address.new(event.first["address"]).checksummed,
        amount: event.last.kwargs[:value],
        tx_hash: event.first["transactionHash"],
        log_index: event.first["logIndex"].to_i(16),
        block_number: event.first["blockNumber"].to_i(16),
        sender: event.last.kwargs[:from],
        receiver: event.last.kwargs[:to]
      )
    end

    def handle_transfer_batch(event)
      event.last.kwargs[:ids].each_with_index do |ticket_id, idx|
        TicketTransactions::TransferBatch.create(
          bc_ticket_id: event.last.kwargs[:ids][idx],
          ticket_factory_contract_address: Eth::Address.new(event.first["address"]).checksummed,
          amount: event.last.kwargs[:values][idx],
          tx_hash: event.first["transactionHash"],
          log_index: event.first["logIndex"].to_i(16),
          block_number: event.first["blockNumber"].to_i(16),
          sender: event.last.kwargs[:from],
          receiver: event.last.kwargs[:to]
        )
      end
    end

    def handle_buy_ticket(event)
      TicketTransactions::BuyTicket.create(
        bc_ticket_id: event.last.kwargs[:ticketId],
        ticket_factory_contract_address: Eth::Address.new(event.first["address"]).checksummed,
        amount: event.last.kwargs[:quantity],
        tx_hash: event.first["transactionHash"],
        log_index: event.first["logIndex"].to_i(16),
        block_number: event.first["blockNumber"].to_i(16),
        receiver: event.last.kwargs[:buyer]
      )
    end

    def handle_locked(event)
      ticket = Ticket.find_by(
        bc_ticket_id: event.last.kwargs[:erc1155id],
        ticket_locker_and_distribution_contract_address: Eth::Address.new(event.first["address"]).checksummed
      )

      TicketTransactions::Lock.create(
        bc_ticket_id: event.last.kwargs[:erc1155id],
        ticket_factory_contract_address: ticket.ticket_factory_contract_address,
        amount: event.last.kwargs[:amount],
        tx_hash: event.first["transactionHash"],
        log_index: event.first["logIndex"].to_i(16),
        block_number: event.first["blockNumber"].to_i(16),
        sender: event.last.kwargs[:owner],
        ticket_locker_and_distribution_contract_address: Eth::Address.new(event.first["address"]).checksummed
      )
    end

    def handle_spend(event)
      TicketTransactions::Spend.create(
        bc_ticket_id: event[:bc_ticket_id],
        ticket_factory_contract_address: event[:ticket_factory_contract_address],
        amount: event[:amount],
        game_mode_id: event[:game_mode_id],
        spend_id: event[:spend_id],
        sender: event[:sender]
      )
    end

    def ticket_factory_contract_addresses
      GameMode.distinct(:ticket_factory_contract_address)
    end

    def ticket_locker_and_distribution_contract_addresses
      GameMode.distinct(:ticket_locker_and_distribution_contract_address)
    end
  end
end
