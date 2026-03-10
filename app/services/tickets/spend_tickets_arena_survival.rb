module Tickets
  class SpendTicketsArenaSurvival < Tickets::BaseSpendTickets
    attr_reader :params

    def initialize(params)
      @params = params
      @players = params[:players]
      @game_id = params[:game_id]
      @entry_type = params[:entry_type]
      @entry_id = params[:entry_id]
      @arena_tf_contract_address = Rails.application.config.ticket_factory_contract_address
      @old_arena_implementation = @game_id.present?
    end

    def call
      unless entry_already_charged?
        if players_have_enough_tickets_deposited
          charge_entry
          return true
        else
          return false
        end
      end

      true
    end

    def players_have_enough_tickets_deposited
      @players.each do |player|
        ticket_balance = TicketBalance.where(
          bc_ticket_id: player[:bc_ticket_id],
          wallet_addr: player[:wallet_addr],
          ticket_factory_contract_address: player[:ticket_factory_contract_address] || @arena_tf_contract_address
        ).first

        if ticket_balance.deposited < 1
          return false
        end
      end
      true
    end

    def redis_key
      @old_arena_implementation ? "GameId::#{@game_id}" : "Entry::#{@entry_type}::#{@entry_id}"
    end
  end
end
