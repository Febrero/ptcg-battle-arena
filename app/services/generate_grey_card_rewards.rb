# game_details = {
#   "MatchType" => "TutorialTraining",
#   "GameId" => "game_xpto_12345_2",
#   "ArenaId" => -1,
#   "GameMode" => "Arena",
#   "GameModeId" => -1,
#   "Season" => 1,
#   "Players" => [
#     {"WalletAddr" => "0x1a98eaf627d65CBa3549bbCc312516Fc1A693670"}
#   ]
# }

class GenerateGreyCardRewards < ApplicationService
  def call(game_details)
    Rails.logger.info "Generating grey card rewards for game: #{game_details["GameId"]}"

    @game_details = game_details

    game_details["Players"].each do |game_player|
      next if game_player["WalletAddr"].blank?

      Rails.logger.info "\tGenerating for player: #{game_player["WalletAddr"]}"

      begin
        grey_card_uids = grey_cards_uids_to_offer(game_player, game_details["MatchType"])

        event_detail = {match_type: game_details["MatchType"]}

        offer_detail = {cards: grey_card_uids.map { |uid| {uid: uid} }, create_starter_deck: game_details["MatchType"] == "TutorialTraining"}

        reward = Rewards::Reward.create(
          wallet_addr: game_player["WalletAddr"],
          value: grey_card_uids.size,
          reward_type: "card",
          reward_subtype: "grey_card",
          source: "battle_arena",
          game_id: game_details["GameId"],
          arena: game_details["ArenaId"],
          game_mode: game_details["GameMode"],
          game_mode_id: game_details["GameModeId"],
          season: game_details["Season"],
          event_detail: event_detail,
          event_type: game_details["GameMode"],
          offer_detail: offer_detail,
          is_correction_event: false
        )

        claim_reward(reward)
      rescue => e
        # ensure that will loop to the next iteration (player)
        Airbrake.notify("GENERATE GREY CARD REWARDS", {
          game_id: game_details["GameId"],
          wallet_addr: game_player["WalletAddr"],
          exception_message: e.message
        })
      end
    end
  end

  private

  def grey_cards_uids_to_offer(game_player, match_type)
    config = Configs::GetConfig.call

    offer_config = case match_type
    when "TutorialTraining"
      config[:tutorial_training_offer_config]
    when "TutorialFriendly"
      config[:tutorial_friendly_offer_config]
    end

    select_grey_cards_from_config(game_player, offer_config)
  end

  # Seleciona grey cards para oferecer dependendo da config fornecida como parametro
  # @note As grey cards não podem ser repetidas e são limitadas (podem ser ganhas)
  # @note Cada iteracao do config é uma regra aplicada sobre as grey cards
  #   - 1ª Iteração 4 ball_stoppers
  #   - 2ª Iteração 4 defenders
  #   ...
  def select_grey_cards_from_config(game_player, config)
    user_grey_card_uids = WalletGreyCard.where(wallet_addr: game_player["WalletAddr"]).distinct(:grey_card_id)
    offered_grey_card_uids = []

    config.each do |spec|
      grey_cards = GreyCard
        .where(spec[:query])
        .nin(uid: user_grey_card_uids)
        .sample(spec[:count])

      grey_card_uids = grey_cards.map(&:uid)
      user_grey_card_uids += grey_card_uids
      offered_grey_card_uids += grey_card_uids
    end

    offered_grey_card_uids
  end

  def won_game(outcome)
    ["2", "win", "w"].include? outcome.to_s.downcase
  end

  def claim_reward(reward)
    return if reward.state == "delivered"

    reward.state_event = "claim"
    reward.save
  end
end
