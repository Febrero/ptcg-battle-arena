require "rails_helper"

RSpec.describe V1::SurvivalPlayers::EntrySerializer, type: :serializer do
  let(:game) { create(:game) }
  let(:survival) { create(:survival) }
  let(:survival_player) do
    create(:survival_player, survival: survival, entries: []).tap do |player|
      player.begin_streak(12345)
      player.update_current_streak_level(game.game_id)
      player.update_current_streak_level(game.game_id)
    end
  end

  subject { V1::SurvivalPlayers::EntrySerializer.new(survival_player.current_entry).serializable_hash }

  describe "attributes" do
    it {
      expect(subject).to include(:levels_completed, :ticket_id, :ticket_amount,
        :ticket_submitted_at, :closed, :closed_at, :games_ids, :level_prize)
    }

    context "entry prize info" do
      it "should return an hash" do
        expect(subject[:level_prize]).to be_a(Hash)
      end

      it "should return the amount of the prize on the stage associated with the levels_completed count" do
        expect(subject[:level_prize][:prize_amount]).to eq(survival.stages.find_by(level: subject[:levels_completed]).prize_amount)
      end

      it "should return the type of prize on the stage associated with the levels_completed count" do
        expect(subject[:level_prize][:prize_type]).to eq(survival.stages.find_by(level: subject[:levels_completed]).prize_type)
      end
    end
  end
end
