require "rails_helper"
RSpec.describe GameType::QuestStreak, type: :model do
  let(:quest) { create(:quest) }
  let(:profile) { create(:quest_profile, quest: quest) }
  let(:streak) { create(:quest_streak, profile: profile, count: 3) }

  describe "#claim" do
    context "when no days have been claimed" do
      it "registers a claim for the first day and returns rewards" do
        rewards = streak.claim
        expect(streak.claims.length).to eq(1)
        expect(streak.claims.first[:day]).to eq(3)
        expect(rewards[:xp]).to eq(600)
        expect(rewards[:fevr]).to eq(1000)
        expect(rewards[:nft]).to eq({common: 3})
        expect(rewards[:ticket]).to eq({"1" => 1})
        expect(rewards[:pack]).to eq({basic: 1, ultra: 2})
      end
    end

    context "when some days have been claimed" do
      before do
        streak.update(claims: [{day: 2, date: Time.now.utc.to_i}])
      end

      it "registers a claim for the next day and returns rewards" do
        rewards = streak.claim
        expect(streak.claims.length).to eq(2)
        expect(streak.claims.last[:day]).to eq(3)
        expect(rewards[:xp]).to eq(300)
        expect(rewards[:fevr]).to eq(0)
        expect(rewards[:nft]).to eq({})
        expect(rewards[:ticket]).to eq({})
        expect(rewards[:pack]).to eq({ultra: 2})
      end
    end

    context "when all days have been claimed" do
      before do
        streak.update(count: 2, claims: [{day: 2, date: Time.now.utc.to_i}])
      end

      it "raises an error" do
        expect { streak.claim }.to raise_error("EVERYTHING_IS_CLAIMED")
        expect(streak.claims.length).to eq(1)
        expect(streak.claims.first[:day]).to eq(2)
      end
    end
  end
end
