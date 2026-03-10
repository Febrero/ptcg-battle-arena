class SpendTickets < ApplicationService
  def call(params)
    Rails.logger.info "Going to spend tickets for params: #{params.inspect}"

    @players = params[:players]
    @game_id = params[:game_id]
    # ! we need to add the game_mode_id => @game_mode_id = params[:game_mode_id]
    @entry_type = params[:entry_type]
    @entry_id = params[:entry_id]
    @arena_tf_contract_address = Rails.application.config.ticket_factory_contract_address
    @game_mode_id = params[:game_mode_id]
    @ticket_amount_needed = GameMode.where(uid: @game_mode_id.to_i).first&.ticket_amount_needed || 1

    # Ensures that if the game_id param is passed (old endpoint used by the FBA client), the old
    # redis flags are still used
    @old_arena_implementation = @game_id.present?

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

  private

  def entry_already_charged?
    redis.get(redis_key) == "charged"
  end

  def players_have_enough_tickets_deposited
    @players.each do |player|
      ticket_balance = TicketBalance.where(
        bc_ticket_id: player[:bc_ticket_id],
        wallet_addr: player[:wallet_addr],
        ticket_factory_contract_address: player[:ticket_factory_contract_address]
      ).first

      if ticket_balance.deposited < @ticket_amount_needed
        return false
      end
    end
    true
  end

  def charge_entry
    @players.each do |player|
      ticket_balance = TicketBalance.where(
        bc_ticket_id: player[:bc_ticket_id],
        wallet_addr: player[:wallet_addr],
        ticket_factory_contract_address: player[:ticket_factory_contract_address]
      ).first
      ticket_balance.deposited -= @ticket_amount_needed
      ticket_balance.save

      # ! This condition can be removed after we start receiving the game mode id
      unless @game_mode_id.nil?
        TicketTransactions::Spend.create(
          game_mode_id: @game_mode_id,
          spend_id: @game_id,
          sender: player[:wallet_addr],
          bc_ticket_id: player[:bc_ticket_id],
          ticket_factory_contract_address: player[:ticket_factory_contract_address] || @arena_tf_contract_address,
          amount: @ticket_amount_needed
        )
      end
    end
    redis.set(redis_key, "charged")
  end

  def redis
    @_redis ||= get_redis
  end

  def redis_key
    @old_arena_implementation ? "GameId::#{@game_id}" : "Entry::#{@entry_type}::#{@entry_id}"
  end
end
