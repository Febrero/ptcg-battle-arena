require "rails_helper"

RSpec.describe GenerateXpPoints do
  let(:player_win) do
    {"WalletAddr" => "0xQweRty",
     "Outcome" => "win",
     "GoalsScored" => 5,
     "GoalsConceded" => 0,
     "Killcount" => 4,
     "Hattricks" => 1,
     "Saves" => 4,
     "DeckPower" => 200,
     "DeckLevel" => 2,
     "RankBeforeGame" => 10,
     "UserId" => "12345",
     "CreatedAt" => (Time.now - 1.week).to_i,
     "Resigned" => false}
  end

  let(:player_loss) do
    {"WalletAddr" => "0xFooBar",
     "Outcome" => "loss",
     "GoalsScored" => 0,
     "GoalsConceded" => 1,
     "Killcount" => 2,
     "Hattricks" => 0,
     "Saves" => 5,
     "DeckPower" => 500,
     "DeckLevel" => 3,
     "UserId" => "67890",
     "CreatedAt" => (Time.now - 2.week).to_i,
     "Resigned" => false}
  end

  let(:game_details) do
    {"GameId" => "ABCD_1661271420_0",
     "GameStartTime" => 1661271420142,
     "MatchType" => "PVP",
     "GameEndTime" => 1661272020142,
     "GameDuration" => 600000,
     "PenaltyShootout" => "Y",
     "GoldenGoal" => "N",
     "Overtime" => "Y",
     "Players" => [player_win, player_loss],
     "RoundNumber" => 1,
     "TurnNumber" => 1}
  end

  let(:play_reward) { create(:reward_config, :play) }
  let(:win_reward) { create(:reward_config, :win) }
  let(:score_5plus_reward) { create(:reward_config, :score_5plus) }
  let(:clean_sheet_reward) { create(:reward_config, :clean_sheet) }
  let(:hattrick_reward) { create(:reward_config, :hattrick) }
  let(:underdog_reward) { create(:reward_config, :underdog) }

  let!(:generate_all_rewards_config) do
    play_reward
    win_reward
    score_5plus_reward
    clean_sheet_reward
    hattrick_reward
    underdog_reward
  end

  context "xp points generation" do
    before do
      allow(Rewards::Reward).to receive(:create)

      subject.instance_variable_set(:@deck_powers, [player_win["DeckPower"], player_loss["DeckPower"]])
      subject.instance_variable_set(:@xp_points_detailed, {})
    end

    it "should calculate a correct amount of points" do
      expected_points = play_reward.achievement_value +
        win_reward.achievement_value +
        score_5plus_reward.achievement_value +
        clean_sheet_reward.achievement_value +
        hattrick_reward.achievement_value +
        underdog_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_win)).to eq(expected_points)
    end

    it "should calculate play point by default" do
      expected_points = play_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end

    it "should calculate win points" do
      player_loss["Outcome"] = "Win"

      expected_points = play_reward.achievement_value + win_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end

    it "should calculate plus 5 score points" do
      player_loss["GoalsScored"] = 5

      expected_points = play_reward.achievement_value + score_5plus_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end

    it "should calculate clean sheet points" do
      player_loss["GoalsConceded"] = 0

      expected_points = play_reward.achievement_value + clean_sheet_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end

    it "should calculate hattrick points" do
      player_loss["Hattricks"] = 1

      expected_points = play_reward.achievement_value + hattrick_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end

    it "should calculate underdog points" do
      subject.instance_variable_set(:@deck_powers, [player_win["DeckPower"], (player_win["DeckPower"] - 1)])

      player_loss.merge!({"Outcome" => "win", "DeckPower" => (player_win["DeckPower"] - 1)})

      expected_points = win_reward.achievement_value +
        play_reward.achievement_value +
        underdog_reward.achievement_value

      expect(subject.send(:calculate_xp_points_in_game, player_loss)).to eq(expected_points)
    end
  end

  it "should generate a new xp reward for each player" do
    allow(Rewards::Reward).to receive(:create)
    allow(subject).to receive(:claim_reward).and_return(nil)

    subject.call(game_details)

    expected_points = play_reward.achievement_value +
      win_reward.achievement_value +
      score_5plus_reward.achievement_value +
      clean_sheet_reward.achievement_value +
      hattrick_reward.achievement_value +
      underdog_reward.achievement_value

    create_rewards_params = {wallet_addr: player_win["WalletAddr"],
                             value: expected_points,
                             reward_type: "xp",
                             source: "battle_arena",
                             game_id: game_details["GameId"],
                             arena: game_details["Arena"],
                             game_mode: game_details["GameMode"],
                             game_mode_id: game_details["GameModeId"],
                             season: game_details["Season"],
                             event_detail: player_win.merge!({xp_detailed: subject.instance_variable_get(:@xp_points_detailed)}),
                             event_type: game_details["GameMode"],
                             is_correction_event: false}

    expect(Rewards::Reward).to have_received(:create).with(create_rewards_params).once
  end

  it "should generate a new xp and set key GameXp for each player in game_details object" do
    allow(Rewards::Reward).to receive(:create)
    allow(subject).to receive(:claim_reward).and_return(nil)

    subject.call(game_details)

    expect(game_details["Players"][0]).to have_key("GameXp")
    expect(game_details["Players"][1]).to have_key("GameXp")
  end

  it "should generate a new xp and generate GameXp values" do
    allow(Rewards::Reward).to receive(:create)
    allow(subject).to receive(:claim_reward).and_return(nil)

    subject.call(game_details)

    expect(game_details["Players"][0]["GameXp"]).to eq(50)
    expect(game_details["Players"][1]["GameXp"]).to eq(20)
  end

  it "should not generate a new xp reward for player without a wallet address" do
    allow(Rewards::Reward).to receive(:create)

    player_win["WalletAddr"] = nil
    player_loss["WalletAddr"] = nil

    subject.call(game_details)

    expect(Rewards::Reward).not_to receive(:create)
  end

  context "rewards for PV" do
  end

  context "claiming a reward" do
    let(:struct) do
      Struct.new(:state) do
        def state_event= event
        end

        def save
        end
      end
    end

    it "should claim an undelivered reward" do
      reward_struct = struct.new("to_claim")

      allow(Rewards::Reward).to receive(:create).and_return(reward_struct)

      expect(reward_struct).to receive(:state_event=).twice
      expect(reward_struct).to receive(:save).twice

      subject.call(game_details)
    end

    it "should not claim an already delivered reward" do
      reward_struct = struct.new("delivered")

      allow(Rewards::Reward).to receive(:create).and_return(reward_struct)

      expect(reward_struct).not_to receive(:state_event=)
      expect(reward_struct).not_to receive(:save)

      subject.call(game_details)
    end
  end

  context "resigning a game" do
    before do
      allow(Rewards::Reward).to receive(:create)
      allow(subject).to receive(:claim_reward).and_return(nil)
    end

    describe "when player resigned" do
      context "for playing" do
        before do
          allow(subject).to receive(:get_win_points).and_return(0)
        end

        it "should give 0 xp if it's on the first 3 turns" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})

          subject.call(game_details)

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: 0)).once
        end

        it "should give 25% xp if it's on the second 3 turns" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})
          game_details.merge!({"RoundNumber" => 1, "TurnNumber" => 4})

          subject.call(game_details)

          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 2})

          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.25).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).twice
        end

        it "should give 50% xp if it's on turn 3 and 4 for the second round" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})
          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 3})

          subject.call(game_details)

          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 4})

          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.5).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).twice
        end

        it "should give 75% xp if it's over turn 3 and 4 on the second round" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})
          game_details.merge!({"RoundNumber" => 3, "TurnNumber" => 1})
          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.75).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).once
        end
      end

      context "for winning" do
        before do
          allow(subject).to receive(:get_play_points).and_return(0)
          allow(subject).to receive(:get_misc_points).and_return(0)
        end

        it "should not receive any points from winning" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})

          subject.call(game_details)

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: 0)).once
        end
      end

      context "for misc events" do
        before do
          allow(subject).to receive(:get_play_points).and_return(0)
          allow(subject).to receive(:get_win_points).and_return(0)
        end

        it "should not receive any points from misc events" do
          player_win.merge!({"Resigned" => true, "Outcome" => "loss"})

          subject.call(game_details)

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: 0)).once
        end
      end
    end

    describe "when opponent resigned" do
      context "for playing" do
        before do
          allow(subject).to receive(:get_win_points).and_return(0)
          allow(subject).to receive(:get_misc_points).and_return(0)
        end

        it "should give 25% for playing if it's on the first 3 turns" do
          player_loss["Resigned"] = true

          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.25).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).once
        end

        it "should give 50% xp for playing if it's on the second 3 turns" do
          player_loss["Resigned"] = true
          game_details.merge!({"RoundNumber" => 1, "TurnNumber" => 4})

          subject.call(game_details)

          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 2})

          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.5).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).twice
        end

        it "should give 75% xp for playing if it's on turn 3 and 4 for the second round" do
          player_loss["Resigned"] = true
          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 3})

          subject.call(game_details)

          game_details.merge!({"RoundNumber" => 2, "TurnNumber" => 4})

          subject.call(game_details)

          play_reward_value = (play_reward.achievement_value * 0.75).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).twice
        end

        it "should give 100% xp for playing if it's over turn 3 and 4 on the second round" do
          player_loss["Resigned"] = true
          game_details.merge!({"RoundNumber" => 3, "TurnNumber" => 1})
          subject.call(game_details)

          play_reward_value = play_reward.achievement_value

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: play_reward_value)).once
        end
      end

      context "for winning" do
        before do
          allow(subject).to receive(:get_play_points).and_return(0)
          allow(subject).to receive(:get_misc_points).and_return(0)
        end

        it "should give 50% xp for winning if it's on the first round" do
          player_loss["Resigned"] = true
          game_details["RoundNumber"] = 1

          subject.call(game_details)

          win_reward_value = (win_reward.achievement_value * 0.5).to_i

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: win_reward_value)).once
        end

        it "should give 100% xp for playing if it's over the first round" do
          player_loss["Resigned"] = true
          game_details["RoundNumber"] = 2
          subject.call(game_details)

          win_reward_value = win_reward.achievement_value

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: win_reward_value)).once
        end
      end

      context "for misc events" do
        before do
          allow(subject).to receive(:get_play_points).and_return(0)
          allow(subject).to receive(:get_win_points).and_return(0)
        end

        it "should not receive any points from misc events" do
          player_win.merge!({"GoalsScored" => 5, "GoalsConceded" => 0, "Hattricks" => 1, "DeckPower" => 10})
          player_loss.merge!({"Resigned" => true, "DeckPower" => 20})

          subject.call(game_details)

          expected_points = score_5plus_reward.achievement_value +
            clean_sheet_reward.achievement_value +
            hattrick_reward.achievement_value +
            underdog_reward.achievement_value

          expect(Rewards::Reward).to have_received(:create).with(hash_including(wallet_addr: player_win["WalletAddr"],
            value: expected_points)).once
        end
      end
    end
  end
end
