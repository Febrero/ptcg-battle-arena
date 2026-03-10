require "rails_helper"

RSpec.describe GameType::Quest, type: :model do
  describe "validations" do
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:type) }
    it { should validate_uniqueness_of(:uid) }
  end

  describe "associations" do
    it { should have_many(:profiles).of_type(GameType::QuestProfile) }
  end

  describe "methods" do
    let(:quest) { create(:quest) }

    describe "#rewards_day" do
      it "returns rewards for the given day" do
        rewards = quest.rewards_day(1)
        expect(rewards[:xp]).to eq(100)
        expect(rewards[:fevr]).to eq(1000)
        expect(rewards[:nft][:common]).to eq(1)
      end
    end

    describe "#summarize" do
      it "returns a summary of the quest rewards for a range of days" do
        summary = quest.summarize(1, 3)
        expect(summary[:xp]).to eq(600)
        expect(summary[:fevr]).to eq(1000)
        expect(summary[:nft][:common]).to eq(3)
        expect(summary[:ticket]["1"]).to eq(1)
        expect(summary[:pack][:basic]).to eq(1)
        expect(summary[:pack][:ultra]).to eq(2)
      end

      it "returns a summary of the quest rewards for all days when no range is provided" do
        summary = quest.summarize
        expect(summary[:xp]).to eq(600)
        expect(summary[:fevr]).to eq(1000)
        expect(summary[:nft][:common]).to eq(3)
        expect(summary[:ticket]["1"]).to eq(1)
        expect(summary[:pack][:basic]).to eq(1)
        expect(summary[:pack][:ultra]).to eq(2)
      end
    end

    describe "#serializer" do
      it "returns a serialized version of the quest rewards" do
        dbl_response = double("Ticket", name: "Lisbon")
        allow(GameMode).to receive(:ticket_from_uid).with(1).and_return(dbl_response)
        serializer = quest.serializer

        expect(serializer.length).to eq(3)
        expect(serializer[0][:level]).to eq(1)
        expect(serializer[0][:prizes][0][:type]).to eq("xp")
        expect(serializer[0][:prizes][0][:amount]).to eq(100)
        expect(serializer[0][:prizes][1][:type]).to eq("fevr")
        expect(serializer[0][:prizes][1][:amount]).to eq(1000)
        expect(serializer[0][:prizes][2][:type]).to eq("nft")
        expect(serializer[0][:prizes][2][:subtype]).to eq("common")
        expect(serializer[0][:prizes][2][:amount]).to eq(1)
      end
    end
  end
end
