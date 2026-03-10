require "rails_helper"

RSpec.describe ProcessGameEvent do
  let!(:season) { create(:season) }
  let(:winner_wallet) { "0xWINAAAAAA" }
  let(:loser_wallet) { "0xLOSAAAAA" }

  let(:game_details_start_log) {
    {
      "IsEndLog" => false,
      "GameId" => "d4fe3",
      "GameLogId" => "game-log-2022-11-24-1938-d4fe3",
      "MatchType" => "PVP",
      "GameStartTime" => Time.now.to_i * 1000,
      "GameMode" => "Arena",
      "GameModeId" => create(:arena).uid,
      "Players" => [
        {
          "WalletAddr" => loser_wallet,
          "DeckId" => "635c42cecb70ce000e350c69",
          "TicketId" => 0,
          "TicketAmount" => 0,
          "DeckPower" => 485,
          "DeckLevel" => 1,
          "RankBeforeGame" => 0
        },
        {
          "WalletAddr" => winner_wallet,
          "DeckId" => "635bd619b589970012dfee4b",
          "TicketId" => 0,
          "TicketAmount" => 0,
          "DeckPower" => 519,
          "DeckLevel" => 1,
          "RankBeforeGame" => 0
        }
      ]
    }
  }

  let(:game_details) {
    {
      "GameId" => "d4fe3",
      "GameLogId" => "game-log-2022-11-24-1938-d4fe3",
      "MatchType" => "PVP",
      "GameStartTime" => Time.now.to_i * 1000,
      "GameEndTime" => 1669319270563,
      "GameDuration" => 583288,
      "PenaltyShootout" => false,
      "GoldenGoal" => false,
      "Overtime" => false,
      "GameMode" => "Arena",
      "GameModeId" => -1,  # create(:arena).uid,
      "Season" => season.uid,
      "Players" => [
        {
          "WalletAddr" => loser_wallet,
          "DeckId" => "635c42cecb70ce000e350c69",
          "TicketId" => 0,
          "TicketAmount" => 0,
          "Outcome" => "loss",
          "GoalsScored" => 11,
          "GoalsConceded" => 14,
          "Killcount" => 0,
          "Hattricks" => 0,
          "Saves" => 0,
          "DeckPower" => 485,
          "DeckLevel" => 1,
          "RankBeforeGame" => 0,
          "Resigned" => false,
          "NFTStats" => {}
        },
        {
          "WalletAddr" => winner_wallet,
          "DeckId" => "635bd619b589970012dfee4b",
          "TicketId" => 0,
          "TicketAmount" => 0,
          "Outcome" => "win",
          "GoalsScored" => 14,
          "GoalsConceded" => 11,
          "Killcount" => 0,
          "Hattricks" => 0,
          "Saves" => 0,
          "DeckPower" => 519,
          "DeckLevel" => 1,
          "RankBeforeGame" => 0,
          "Resigned" => false,
          "NFTStats" => {}
        }
      ]
    }
  }
  let(:game_details_lite) {
    game_details_lite = game_details.deep_dup
    game_details_lite["Players"].each do |element|
      element.except!("NFTStats")
    end

    game_details_lite
  }

  before do
    # allow(Arenas::GeneratePrize).to receive(:call).with(any_args)

    # allow(GenerateXpPoints).to receive(:call).with(game_details)

    # allow(SendGameNftsStatsToKafka).to receive(:call).with(any_args)
    # allow(SendGameEventToLeaderboardsKafka).to receive(:call).with(any_args)
    # allow(SendGameEventToKafka).to receive(:call).with(any_args)

    allow(Arenas::GeneratePrize).to receive(:call)
    allow(Arenas::CalculatePrizeValue).to receive(:call)
    allow(GenerateXpPoints).to receive(:call)
    allow(SendGameEventToLeaderboardsKafka).to receive(:call)
    allow(SendGameEventToKafka).to receive(:call)
    allow(SendGameNftsStatsToKafka).to receive(:call)
  end

  it "check game start log" do
    allow(Arenas::ProcessGame).to receive(:call).with(any_args)
    ProcessGameEvent.call(game_details_start_log)
    expect(Game.count).to eq(1)
    expect(Game.first.state).to eq("game_start_log")
    expect(Arenas::ProcessGame).not_to have_received(:call).with(any_args)
    expect(SendGameEventToKafka).not_to have_received(:call).with(any_args)
  end

  it "check game end log" do
    ProcessGameEvent.call(game_details_start_log)
    allow(Arenas::ProcessGame).to receive(:call).with(any_args)
    ProcessGameEvent.call(game_details.merge({"IsEndLog" => true}))
    expect(Game.count).to eq(1)
    expect(Game.first.state).to eq("game_end_log")
    expect(Arenas::ProcessGame).to have_received(:call).with(any_args)
    expect(SendGameEventToKafka).to have_received(:call).with(any_args)
  end

  #------ DB DATA PERSIST
  it "persist game details received" do
    ProcessGameEvent.call(game_details)

    expect(Game.count).to eq(1)
    expect(Game.first.players.count).to eq(2)
  end

  it "persist game details received if game_mode_id is invalid" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    game_details["GameModeId"] = -1000

    ProcessGameEvent.call(game_details)

    expect(Game.count).to eq(1)
    expect(Game.first.players.count).to eq(2)
  end

  it "should denormalize winner info to game" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    ProcessGameEvent.call(game_details)

    expect(Game.find_by(game_id: "d4fe3").winner).to eq(winner_wallet)
  end

  it "should denormalize resignation info to game (no player resigned)" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    ProcessGameEvent.call(game_details)

    expect(Game.find_by(game_id: "d4fe3").any_player_resigned).to be_falsy
  end

  it "should denormalize resignation info to game (one player resigned)" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    game_details["Players"].first["Resigned"] = true

    ProcessGameEvent.call(game_details)

    expect(Game.find_by(game_id: "d4fe3").any_player_resigned).to be_truthy
  end

  it "should have be a winner if the outcome is a winning one" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    ProcessGameEvent.call(game_details)

    expect(GamePlayer.find_by(wallet_addr: winner_wallet).winner).to be_truthy
  end

  it "should not be a winner if the outcome is not a winning one" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    ProcessGameEvent.call(game_details)

    expect(GamePlayer.find_by(wallet_addr: loser_wallet).winner).to be_falsey
  end

  it "should create db instances for all players" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    expect {
      ProcessGameEvent.call(game_details)
    }.to change {
      GamePlayer.count
    }.by(2)
  end

  it "should create and ignore duplicated received" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    ProcessGameEvent.call(game_details)

    game_details["Players"][0]["DeckPower"] = 486
    ProcessGameEvent.call(game_details)

    expect(GamePlayer.count).to eq(2)
    expect(GamePlayer.where(wallet_addr: loser_wallet).first.deck_power).to eq(485)
  end

  it "should update db instances for all players" do
    ProcessGameEvent.call(game_details)

    game_details["Correction"] = true
    game_details["Players"][0]["DeckPower"] = 486
    ProcessGameEvent.call(game_details)
    game_details.delete("Correction")

    expect(GamePlayer.count).to eq(2)
    expect(GamePlayer.where(wallet_addr: loser_wallet).first.deck_power).to eq(486)
  end

  #------ BOTS UPDATE
  it "should increment bots daily game counter" do
    expect(AssistedGamers::IncrementDailyGame).to receive(:call)

    ProcessGameEvent.call(game_details)
  end

  #------ BAN PERIOD SET
  it "should set a ban period for a player that resigned" do
    game_details["Players"].first["Resigned"] = true

    expect(SetBanPeriod).to receive(:call)

    ProcessGameEvent.call(game_details)
  end

  it "should not set any ban period if no one resigned" do
    expect(SetBanPeriod).not_to receive(:call)

    ProcessGameEvent.call(game_details)
  end

  #------ EARLY RETURN FLOWS
  it "should return and notify airbrake if a game was resubmitted without corrections" do
    ProcessGameEvent.call(game_details)

    expect(Airbrake).to receive(:notify)

    ProcessGameEvent.call(game_details)

    expect(SendGameEventToKafka).to have_received(:call).once
  end

  it "should not continue processing if the round number is 0 and is not a playoff" do
    game_details["RoundNumber"] = 0

    ProcessGameEvent.call(game_details)

    expect(SendGameEventToKafka).not_to have_received(:call)
  end

  it "should continue processing if the round number is 0 and is a playoff" do
    game_details["RoundNumber"] = 0
    game_details["MatchType"] = "Playoff"
    game_details["GameMode"] = "Playoff"
    game_details["GameModeId"] = create(:playoff, :with_ticket_config).uid

    allow(Playoffs::ProcessGame).to receive(:call)

    ProcessGameEvent.call(game_details)

    expect(SendGameEventToKafka).to have_received(:call).once
  end

  #------ ARENA GAME MODE PROCESSING
  it "should call arena specific processing for ARENA match_type" do
    game_details["MatchType"] = "Arena"
    game_details["GameModeId"] = create(:arena).uid

    expect(Arenas::ProcessGame).to receive(:call).with(any_args)

    ProcessGameEvent.call(game_details)
  end

  it "should call arena specific processing for PVE match_type" do
    game_details["MatchType"] = "PVE"

    expect(Arenas::ProcessGame).to receive(:call).with(any_args)

    ProcessGameEvent.call(game_details)
  end

  it "should call arena specific processing for PVP match_type" do
    expect(Arenas::ProcessGame).to receive(:call).with(any_args)

    ProcessGameEvent.call(game_details)
  end

  it "should create a user activity if arena" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    game_details["MatchType"] = "Arena"
    game_details["GameModeId"] = create(:arena).uid

    ProcessGameEvent.call(game_details)

    expect(UserActivity.where("event_info.game_id": game_details["GameId"]).count).to eq(2)
  end

  it "should not create a user activity if exists" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    game_details["MatchType"] = "Arena"
    game_details["GameModeId"] = create(:arena).uid

    ProcessGameEvent.call(game_details)
    ProcessGameEvent.call(game_details)

    expect(UserActivity.where("event_info.game_id": game_details["GameId"]).count).to eq(2)
  end

  #------ PLAYOFF GAME MODE PROCESSING
  it "should call arena specific processing for PLAYOFF match_type" do
    playoff = create(:playoff, :with_ticket_config)

    game_details["MatchType"] = "Playoff"
    game_details["GameMode"] = "Playoff"
    game_details["GameModeId"] = playoff.uid

    expect(Playoffs::ProcessGame).to receive(:call).with(any_args)

    ProcessGameEvent.call(game_details)
  end

  #------ SURVIVAL GAME MODE PROCESSING
  it "should call arena specific processing for SURVIVAL match_type" do
    game_details["MatchType"] = "Survival"
    game_details["GameMode"] = "Survival"
    game_details["GameModeId"] = create(:survival).uid

    expect(Survivals::ProcessGame).to receive(:call).with(any_args)

    ProcessGameEvent.call(game_details)
  end

  #------ XP GENERATION
  ["Arena", "PVE", "PVP", "Playoff", "Survival", "TutorialFriendly"].each do |match_type|
    send(:it, "should generate xp for #{match_type} games") do
      game_details["MatchType"] = match_type

      expect(GenerateXpPoints).to receive(:call).with(game_details_lite)
      ProcessGameEvent.call(game_details)
    end
  end

  it "should not generate xp for playoff game with round number 0" do
    game_details["RoundNumber"] = 0
    game_details["MatchType"] = "playoff"

    expect(GenerateXpPoints).not_to receive(:call)
    ProcessGameEvent.call(game_details)
  end

  it "should not generate xp if the game already existed" do
    ProcessGameEvent.call(game_details)

    game_details["Correction"] = true

    ProcessGameEvent.call(game_details)

    expect(GenerateXpPoints).to have_received(:call).once
  end

  #------ DAILY GAMES QUEST REGISTRATION
  ["Arena", "Playoff", "Survival"].each do |match_type|
    send(:it, "should register daily quest for #{match_type} games") do
      game_details["MatchType"] = match_type

      expect(RegisterQuestMilestones).to receive(:call).with(game_details_lite)
      ProcessGameEvent.call(game_details)
    end
  end

  it "should not register daily quest for playoff game with round number 0" do
    game_details["RoundNumber"] = 0
    game_details["MatchType"] = "playoff"

    expect(RegisterQuestMilestones).not_to receive(:call)
    ProcessGameEvent.call(game_details)
  end

  it "should not register daily quest if the game already existed" do
    allow(RegisterQuestMilestones).to receive(:call)

    ProcessGameEvent.call(game_details)

    game_details["Correction"] = true

    ProcessGameEvent.call(game_details)

    expect(RegisterQuestMilestones).to have_received(:call).once
  end

  #------ GENERATE GREY CARDS REWARDS
  ["TutorialTraining", "TutorialFriendly"].each do |match_type|
    send(:it, "should generate grey card rewards for #{match_type} games") do
      game_details["MatchType"] = match_type

      expect(GenerateGreyCardRewards).to receive(:call).with(game_details_lite)
      ProcessGameEvent.call(game_details)
    end
  end

  ["TutorialTraining", "TutorialFriendly"].each do |match_type|
    send(:it, "should not generate grey card rewards for #{match_type} games if the player resigned") do
      game_details["MatchType"] = match_type
      game_details["Players"].first["Resigned"] = true

      expect(GenerateGreyCardRewards).not_to receive(:call).with(game_details_lite)
      ProcessGameEvent.call(game_details)
    end
  end

  it "should not generate grey card rewards if the game already existed" do
    allow(GenerateGreyCardRewards).to receive(:call)

    game_details["MatchType"] = "TutorialFriendly"

    ProcessGameEvent.call(game_details)

    game_details["Correction"] = true

    ProcessGameEvent.call(game_details)

    expect(GenerateGreyCardRewards).to have_received(:call).once
  end

  #------ NFT STATS
  it "should send NFTSTATS to Kafka" do
    expect(SendGameNftsStatsToKafka).to receive(:call).with(game_details)
    ProcessGameEvent.call(game_details)
  end

  it "should not send NFTSTATS to kafka if it's a tutorial training" do
    game_details["MatchType"] = "TutorialTraining"

    expect(SendGameNftsStatsToKafka).not_to receive(:call)
    ProcessGameEvent.call(game_details)
  end

  it "should not send NFTSTATS to kafka if it's a tutorial friendly" do
    game_details["MatchType"] = "TutorialFriendly"

    expect(SendGameNftsStatsToKafka).not_to receive(:call)
    ProcessGameEvent.call(game_details)
  end

  it "should not register daily quest for playoff game with round number 0" do
    game_details["RoundNumber"] = 0
    game_details["MatchType"] = "playoff"

    expect(SendGameNftsStatsToKafka).not_to receive(:call)
    ProcessGameEvent.call(game_details)
  end

  #------ FULL PROCESS
  it "should send game event to kafka at the end of the process" do
    expect(SendGameEventToKafka).to receive(:call).with(game_details_lite)

    ProcessGameEvent.call(game_details)
  end

  it "should not break the processing when a exception is raised (should send it to airbrake)" do
    allow(SendGameNftsStatsToKafka).to receive(:call)
    allow(Airbrake).to receive(:notify)

    ProcessGameEvent.call(nil)

    expect(Airbrake).to have_received(:notify).once
  end

  it "should not exist a processing key on redis at the end" do
    get_redis.set("#{game_details["GameId"]}::processing", "1")

    ProcessGameEvent.call(game_details)

    expect(get_redis.get("#{game_details["GameId"]}::processing")).to be_nil
  end
end
