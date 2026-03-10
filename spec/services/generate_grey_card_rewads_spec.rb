require "rails_helper"

# Assuming you have configured RSpec and loaded your Rails environment correctly.

RSpec.describe GenerateGreyCardRewards do
  let(:game_details) do
    {
      "MatchType" => match_type,
      "GameId" => "sample_game_id",
      "Players" => [
        {
          "WalletAddr" => "player1_wallet",
          "Outcome" => outcome
        }
      ],
      "ArenaId" => "sample_arena_id",
      "GameMode" => "sample_game_mode",
      "GameModeId" => "sample_game_mode_id",
      "Season" => "sample_season"
    }
  end

  let(:match_type) { "TutorialTraining" }
  let(:outcome) { "win" }

  describe "#call" do
    context "when the match type is TutorialTraining and player wins" do
      it "generates grey card rewards for the player" do
        service = GenerateGreyCardRewards.new
        allow(service).to receive(:grey_cards_uids_to_offer).and_return(["grey_card_uid1"])
        allow(Rewards::Reward).to receive(:create).and_return(double(save: true, state: "pending"))
        allow(service).to receive(:claim_reward)

        service.call(game_details)

        expect(service).to have_received(:claim_reward)
      end
    end

    context "when the match type is TutorialFriendly and player wins" do
      let(:match_type) { "TutorialFriendly" }

      it "generates grey card rewards for the player" do
        service = GenerateGreyCardRewards.new
        allow(service).to receive(:grey_cards_uids_to_offer).and_return(["grey_card_uid1"])
        allow(Rewards::Reward).to receive(:create).and_return(double(save: true, state: "pending"))
        allow(service).to receive(:claim_reward)

        service.call(game_details)

        expect(service).to have_received(:claim_reward)
      end
    end

    context "when the player has a blank WalletAddr" do
      it "does not generate rewards for the player" do
        game_details["Players"][0]["WalletAddr"] = ""
        service = GenerateGreyCardRewards.new
        allow(service).to receive(:grey_cards_uids_to_offer).and_return(["grey_card_uid1"])
        allow(Rewards::Reward).to receive(:create)
        allow(service).to receive(:claim_reward)

        service.call(game_details)

        expect(service).not_to have_received(:claim_reward)
      end
    end
  end
end
