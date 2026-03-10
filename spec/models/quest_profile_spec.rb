require "rails_helper"

RSpec.describe GameType::QuestProfile, type: :model do
  describe "validations" do
    it { should validate_presence_of(:wallet_addr) }
    it { should validate_presence_of(:quest) }
  end

  describe "associations" do
    it { should belong_to(:quest).of_type(GameType::Quest) }
    it { should have_many(:streaks).of_type(GameType::QuestStreak) }
  end

  describe "methods" do
    let!(:season) { create(:season) }
    let!(:quest) { create(:quest) }
    let!(:profile) { create(:quest_profile, quest: quest) }
    let!(:streak) { create(:quest_streak, profile: profile, count: profile.count, claims: profile.claims, end_date: nil) }
    # let(:profile) { create(:quest_profile_with_streaks, streak_count: 5) }

    describe "#new_milestone" do
      it "updates the last_game_played date and increments count if n_days is nil or 1" do
        expect {
          profile.new_milestone(DateTime.now)
        }.to change(profile, :last_game_played)

        expect(profile.count).to eq(1)
      end

      it "closes the current streak and creates a new one if n_days is greater than 1" do
        profile.update(last_game_played: (DateTime.now - 3.days).to_date, count: 3, days_to_rewards: [1, 2, 3])
        expect {
          profile.new_milestone(DateTime.now)
        }.to change(GameType::QuestStreak, :count).by(1)

        expect(profile.count).to eq(1)
        expect(profile.days_to_rewards).to eq([1])
        expect(profile.claims.count).to eq(1)
      end

      # it "calls close_streak if the last day of the quest is played" do
      #   profile.update(count: 2, last_game_played: DateTime.now - 1.day)
      #   expect(profile).to receive(:close_streak).once
      #   profile.new_milestone(DateTime.now)
      # end
    end

    describe "#is_last_day_of_quest" do
      it "returns true if count is equal to the length of the quest config" do
        profile.update(count: quest.config.count)
        expect(profile.is_last_day_of_quest).to eq(true)
      end

      it "returns false if count is less than the length of the quest config" do
        profile.update(count: quest.config.count - 1)
        expect(profile.is_last_day_of_quest).to eq(false)
      end
    end

    describe "#update_actual_streak" do
      it "increments count, adds to days_to_rewards, and closes the streak if it is the last day of the quest" do
        expect {
          profile.update_actual_streak(DateTime.now)
        }.to change(profile, :count).by(1)
        expect(profile.days_to_rewards).to eq([1])
        expect(UserActivity.where("event_info.day": profile.count).count).to eq(1)
        expect(profile.streaks.count).to eq(1)

        # profile.update(count: quest.config.count - 1)
        # expect {
        #   profile.update_actual_streak(DateTime.now)
        # }.to change(GameType::QuestStreak, :count).by(1)
        # expect(profile.count).to eq(0)
        # expect(profile.days_to_rewards).to eq([])
      end
    end

    describe "#claim" do
      it "raises an exception if there are no days to be claimed" do
        expect {
          profile.claim
        }.to raise_error("NO_DAYS_TO_BE_CLAIMED")
      end

      it "registers a claim and returns the rewards" do
        profile.update(days_to_rewards: [1, 2], claims: [{day: 1, date: DateTime.now - 1.day}])
        rewards = profile.quest.summarize(2, 2)

        expect {
          profile.claim
        }.to change(profile, :claims)
        expect(profile.claims.last).to include(day: 2)
        expect(profile.claims.last[:date]).to be_within(1.second).of(DateTime.now.utc.to_i)

        expect(rewards[:xp]).to eq(quest.config[1][:xp] || 0)
        expect(rewards[:fevr]).to eq(quest.config[1][:fevr] || 0)
        expect(rewards[:nft]).to eq(quest.config[1][:nft] || {})
        expect(rewards[:ticket]).to eq(quest.config[1][:ticket] || {})
        expect(rewards[:pack]).to eq(quest.config[1][:pack] || {})
      end
    end

    describe "#close_streak" do
      it "finish a QuestStreak record and resets the current streak" do
        claims = [{day: 1, date: (DateTime.now - 1.day).utc.to_i}]
        last_game_played_at = (DateTime.now - 2.days).utc.to_i
        profile.update(count: 3, last_game_played: last_game_played_at, claims: claims)
        last_game_played_at = profile.last_game_played
        profile.close_streak
        expect(profile.count).to eq(0)
        expect(profile.days_to_rewards).to be_empty
        expect(profile.claims).to be_empty
        expect(GameType::QuestStreak.last.count).to eq(3)
        expect(GameType::QuestStreak.last.end_date).to eq(last_game_played_at)
        array_with_symbols = GameType::QuestStreak.last.claims.map { |hash| hash.transform_keys(&:to_sym) }
        expect(array_with_symbols).to eq(claims)
      end
    end

    describe "#reset_current_streak" do
      it "resets the count, days_to_rewards, and claims attributes" do
        profile.update(count: 3, days_to_rewards: [1, 2, 3], claims: [{day: 1, date: DateTime.now - 1.day}])
        profile.reset_current_streak
        expect(profile.count).to eq(0)
        expect(profile.days_to_rewards).to be_empty
        expect(profile.claims).to be_empty
      end
    end
  end
end
