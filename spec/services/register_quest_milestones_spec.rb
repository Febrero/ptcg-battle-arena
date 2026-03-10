require "rails_helper"

RSpec.describe RegisterQuestMilestones, type: :service do
  describe "#call" do
    let!(:season) { create(:season) }
    let(:game_start_time) { Time.now.to_i * 1000 }
    let(:game_date) { Time.at(game_start_time / 1000).to_datetime }
    let!(:quest) { create(:quest, active: true) }
    let(:game_details) do
      {
        "GameStartTime" => game_start_time,
        "MatchType" => "Arena",
        "Players" => [{"WalletAddr" => "0x123", "Score" => 10}, {"WalletAddr" => nil, "Score" => 20}, {"WalletAddr" => "0x456", "Score" => 30}]
      }
    end
    let(:game_details_arena) do
      {
        "GameStartTime" => game_start_time,
        "GameMode" => "Arena",
        "Players" => [{"WalletAddr" => "0x123", "Score" => 10}, {"WalletAddr" => "0x456", "Score" => 30}]
      }
    end

    before do
      allow(Rewards::Reward).to receive(:create)
      allow_any_instance_of(RegisterQuestMilestones).to receive(:claim_reward)
    end

    it "calls quest_profile_milestone for each player with a wallet address" do
      service = RegisterQuestMilestones.new
      expect(service).to receive(:quest_profile_milestone).with("0x123", game_date).and_return({})
      expect(service).not_to receive(:quest_profile_milestone).with(nil, game_date)
      expect(service).to receive(:quest_profile_milestone).with("0x456", game_date).and_return({})

      service.call(game_details)
    end

    it "calls quest_profile_milestone for each player with a wallet address" do
      service = RegisterQuestMilestones.new
      expect(service).to receive(:quest_profile_milestone).with("0x123", game_date).and_return({})
      expect(service).not_to receive(:quest_profile_milestone).with(nil, game_date)
      expect(service).to receive(:quest_profile_milestone).with("0x456", game_date).and_return({})

      service.call(game_details)
    end

    it "not calls quest_profile_milestone for each player on practice(PVE)" do
      service = RegisterQuestMilestones.new
      expect(service).not_to receive(:quest_profile_milestone).with("0x123", game_date)
      expect(service).not_to receive(:quest_profile_milestone).with("0x456", game_date)

      service.call(game_details_arena.merge({"GameModeId" => -1}))
    end

    it "not calls quest_profile_milestone for each player on FreeForAll when resign on round 1 (PVP)" do
      service = RegisterQuestMilestones.new
      expect(service).not_to receive(:quest_profile_milestone).with("0x123", game_date)
      expect(service).not_to receive(:quest_profile_milestone).with("0x456", game_date)

      service.call(game_details_arena.merge({"GameModeId" => -2, "RoundNumber" => 1}))
    end

    it "calls quest_profile_milestone for each player on Arena in any resign" do
      service = RegisterQuestMilestones.new
      expect(service).to receive(:quest_profile_milestone).with("0x123", game_date)
      expect(service).to receive(:quest_profile_milestone).with("0x456", game_date)

      service.call(game_details_arena.merge({"GameMode" => "Arena", "MatchType" => "Arena", "GameModeId" => 1, "RoundNumber" => 1}))
    end

    it "calls quest_profile_milestone for each player on Survival in any resign" do
      service = RegisterQuestMilestones.new
      expect(service).to receive(:quest_profile_milestone).with("0x123", game_date)
      expect(service).to receive(:quest_profile_milestone).with("0x456", game_date)

      service.call(game_details_arena.merge({"GameMode" => "Survival", "MatchType" => "Arena", "GameModeId" => 1, "RoundNumber" => 1}))
    end

    it "creates or finds quest profiles for each player with a wallet address" do
      service = RegisterQuestMilestones.new
      create(:quest_profile, wallet_addr: "0x123", quest: quest)
      expect(GameType::QuestProfile.count).to eq(1)

      service.call(game_details)

      expect(GameType::QuestProfile.count).to eq(2)
      expect(GameType::QuestProfile.where(wallet_addr: "0x123", quest_id: quest.uid)).to exist
      expect(GameType::QuestProfile.where(wallet_addr: "0x456", quest_id: quest.uid)).to exist
    end

    it "calls new_milestone for each quest profile" do
      service = RegisterQuestMilestones.new

      profile1 = create(:quest_profile, wallet_addr: "0x123", quest: quest)
      profile2 = create(:quest_profile, wallet_addr: "0x456", quest: quest)

      allow(GameType::QuestProfile).to receive_message_chain(:where, :first_or_create).and_return(profile1, profile2)

      expect(profile1).to receive(:new_milestone).with(game_date)
      expect(profile2).to receive(:new_milestone).with(game_date)

      service.call(game_details)
    end
  end

  describe "#quest_profile_milestone" do
    let(:wallet_addr) { "0x123" }
    let(:game_date) { Time.now.to_datetime }
    let(:quest) { create(:quest, active: true) }
    before do
      allow(Rewards::Reward).to receive(:create)
      allow(subject).to receive(:claim_reward).and_return(nil)
    end

    context "when there is an active quest" do
      let!(:quest_profile) { create(:quest_profile, wallet_addr: wallet_addr, quest: quest) }

      it "returns the result of new_milestone" do
        result = {fevr: 1000, nft: {"common" => 1}, pack: {}, ticket: {}, xp: 100}

        allow(GameType::QuestProfile).to receive_message_chain(:where, :first_or_create).and_return(quest_profile)

        expect(quest_profile).to receive(:new_milestone).with(game_date).and_return(result)

        service = RegisterQuestMilestones.new
        expect(service.quest_profile_milestone(wallet_addr, game_date)).to eq(result)
      end
    end

    context "when there is no active quest" do
      it "returns an empty hash" do
        service = RegisterQuestMilestones.new
        expect(service.quest_profile_milestone(wallet_addr, game_date)).to eq({})
      end
    end
  end
end
