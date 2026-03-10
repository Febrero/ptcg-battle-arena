require "rails_helper"

RSpec.describe Survival, type: :model do
  subject { described_class.new }

  describe "indexes" do
    it { is_expected.to have_index_for(state: 1).with_options(name: "state_index", background: true, sparse: true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:levels_count) }
  end

  describe "associations" do
    it { is_expected.to have_many(:survival_players) }
  end

  describe "state machine" do
    it { expect(subject).to transition_from(:incoming).to(:active).on_event(:open) }
    it { expect(subject).to transition_from(:closed).to(:active).on_event(:reopen) }
    it { expect(subject).to transition_from(:active).to(:closed).on_event(:close, :finish_survival_players_streaks) }
    it { expect(subject).to transition_from(:closed).to(:archived).on_event(:archive) }

    context "incoming state (initial)" do
      it { expect(subject).to allow_event(:open) }
      it { expect(subject).to_not allow_event(:reopen) }
      it { expect(subject).to_not allow_event(:close) }
      it { expect(subject).to_not allow_event(:archive) }
    end

    context "active state" do
      let(:active_survival) { create(:survival, :active) }

      it { expect(active_survival).to_not allow_event(:open) }
      it { expect(active_survival).to_not allow_event(:reopen) }
      it { expect(active_survival).to allow_event(:close) }
      it { expect(active_survival).to_not allow_event(:archive) }
    end

    context "closed state" do
      let(:active_survival) { create(:survival, :closed) }

      it { expect(active_survival).to_not allow_event(:open) }
      it { expect(active_survival).to allow_event(:reopen) }
      it { expect(active_survival).to_not allow_event(:close) }
      it { expect(active_survival).to allow_event(:archive) }

      xit "should finish all open entries when the survival is closed" do
      end
    end

    context "archived state" do
      let(:active_survival) { create(:survival, :archived) }

      it { expect(active_survival).to_not allow_event(:open) }
      it { expect(active_survival).to_not allow_event(:reopen) }
      it { expect(active_survival).to_not allow_event(:close) }
      it { expect(active_survival).to_not allow_event(:archive) }
    end
  end
end
