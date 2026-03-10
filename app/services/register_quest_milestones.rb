class RegisterQuestMilestones < ApplicationService
  def call game_details
    quest = GameType::Quest.where(active: true).first
    return unless quest

    game_date = Time.at(game_details["GameStartTime"] / 1000).to_datetime

    game_details["Players"].each do |game_player|
      next if game_player["WalletAddr"].blank?
      next if exclusion_match?(game_details, game_player)

      begin
        rewards_to_be_distributed, day_quest, quest_streak_id = quest_profile_milestone(game_player["WalletAddr"], game_date)
        # here we should call script that will save rewards and distribute it

        register_rewards(rewards_to_be_distributed, day_quest, quest_streak_id.to_s, game_player, game_details)
      rescue => e
        # ensure that will loop to the next iteration (player)
        Airbrake.notify("QUEST NOT PROCESSED", {
          game_id: game_details["GameId"],
          wallet_addr: game_player["WalletAddr"],
          exception_message: e.message
        })
      end
    end
  end

  def exclusion_match?(game_details, game_player)
    return true if should_exclude_by_match_type?(game_details)

    false
  end

  def quest_profile_milestone(wallet_addr, game_date)
    # maybe here the criteria should be different
    quest = GameType::Quest.where(active: true).first
    return {} unless quest

    profile = GameType::QuestProfile.where(wallet_addr: wallet_addr, quest: quest).first_or_create do |p|
      p.wallet_addr = wallet_addr
      p.quest = quest
    end

    profile.new_milestone(game_date)
  end

  def register_rewards(rewards_to_be_distributed, day_quest, quest_streak_id, game_player, game_details)
    quest_details = {from: "DailyQuest", day_quest: day_quest, quest_streak_id: quest_streak_id}

    game_player.merge!(quest_details)

    rewards_to_be_distributed&.each do |reward_type, value|
      register_reward(reward_type, value, game_player, game_details) if valid_numeric?(value)

      if value.is_a?(Hash) && !value.empty?
        value.each do |type, type_value|
          register_reward(reward_type, type_value, game_player, game_details, type)
        end
      end
    end
  end

  def valid_numeric?(value)
    value.is_a?(Numeric) && value > 0
  end

  def register_reward(reward_type, value, game_player, game_details, reward_subtype = nil)
    # expected configuration
    # [{"xp"=>25}, {"xp"=>15, "fevr"=>250}, {"xp"=>500, "ticket"=>{"1"=>1}, "pack"=>{"basic##1"=>1}, "nft"=>{"common"=>1}}]
    # [{"xp"=>25}, {"xp"=>15, "fevr"=>250}, {"xp"=>500, "ticket"=>{"1"=>1}, "pack"=>{"basic"=>1}, "nft"=>{"common"=>1}}]
    # [{"xp"=>25}, {"xp"=>15, "fevr"=>250}, {"xp"=>500, "ticket"=>{"1"=>1}, "pack"=>{"basic"=>1}, "nft"=>{"common##1,2,4"=>1}}]
    # change name to uid and change serialzier on endpoint

    offer_detail = {}
    return if reward_type.to_s.downcase == "avatar"

    case reward_type.to_s.downcase
    when "ticket"
      game_mode = GameMode.where(uid: reward_subtype.to_i).first

      raise TicketNotFound.new("Check ticket uid: #{reward_subtype}") unless game_mode

      offer_detail = {
        bc_ticket_id: [game_mode.ticket_id_to_offer],
        ticket_factory_contract_address: game_mode.ticket_factory_contract_address
      }

      reward_subtype = nil
    when "pack", "nft"
      if reward_subtype.include?("##")
        name_dropuid = reward_subtype.split("##")
        reward_subtype = name_dropuid.first
        drop_uids = name_dropuid.last.split(",").map(&:to_i)
        offer_detail = {
          drop_uid: drop_uids
        }
      end

    end

    event_detail = game_player.deep_dup
    event_detail.delete("xp_detailed")
    event_detail["xp_detailed"] = {"daily quest day #{game_player[:day_quest]}" => {amount: 1, xp_points: value}}

    reward = Rewards::Reward.create(
      wallet_addr: game_player["WalletAddr"],
      value: value,
      reward_type: reward_type.to_s,
      source: "battle_arena",
      game_id: game_details["GameId"],
      arena: game_details["GameModeId"],
      game_mode: game_details["GameMode"],
      game_mode_id: game_details["GameModeId"],
      season: game_details["Season"],
      event_detail: event_detail,
      event_type: "DailyGame",
      reward_subtype: reward_subtype,
      offer_detail: offer_detail,
      is_correction_event: false
    )

    claim_reward(reward)
  rescue TicketNotFound => e
    Airbrake.notify(e)
  end

  def claim_reward reward
    return if reward.state == "delivered"

    reward.state_event = "claim"
    reward.save
  end

  private

  def should_exclude_by_match_type?(game_details)
    game_details["GameMode"] == "Arena" &&
      (
        game_details["GameModeId"].to_i == -1 || # is practice
        game_details["GameModeId"].to_i == -2 # free for all
      )
  end
end
