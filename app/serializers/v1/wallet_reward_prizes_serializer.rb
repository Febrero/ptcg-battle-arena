module V1
  class WalletRewardPrizesSerializer < WalletRewardSerializer
    attributes :token_contract

    def total_value
      GameMode.find_by(uid: object["game_mode_id"]).prize_pool_winner_share.to_s
    end

    def wallet_addr
      object["wallet_addr"]
    end

    def token_contract
      object["erc20"]
    end

    def reward_type
      object["erc20_name"]
    end
  end
end
