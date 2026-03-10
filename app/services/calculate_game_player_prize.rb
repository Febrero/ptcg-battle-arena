class CalculateGamePlayerPrize < ApplicationService
  attr_accessor :game, :game_details, :game_mode, :game_player

  def call game, game_details, player_wallet_addr
    @game = game
    @game_details = game_details
    @game_mode = game.game_mode
    # attention game_id is there  the foreign key to game
    @game_player = GamePlayer.where(game_id: game.id, wallet_addr: player_wallet_addr).first

    Rails.logger.info "Custom prize calculation for game: #{game.id}\n\tgame_mode: #{game.game_mode_id}"

    prize_amount, prize_type = get_prize_info

    # Update game_player
    # ??? update the game with prize
    game_player.update_attributes(prize_amount: prize_amount, prize_type: prize_type)

    # Update game_details event in battle/arena mode its necessary
    if game_details
      player_game_detail = game_details["Players"].detect { |player_details| player_details["WalletAddr"] == player_wallet_addr }
      player_game_detail["PrizeAmount"] = prize_amount
      player_game_detail["PrizeType"] = prize_type
    end

    [prize_amount, prize_type]
  end

  protected

  # @abstract Implement for getting the prize info from the game_mode
  #
  # @note Prize info should be the value and type of the token that is going to be given to the player
  #
  # @return [Array<String>] A 2 position array, being the first the value and the later the type
  #
  def get_prize_info
    log "NotImplementedError: #{self.class.name}#get_prize_info"
    raise NotImplementedError
  end
end
