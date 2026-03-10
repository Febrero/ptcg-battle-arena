# spec/models/tutorial_progress_spec.rb

require "rails_helper"

RSpec.describe TutorialProgress, type: :model do
  describe "Associations" do
    it { is_expected.to embed_many(:steps) }
  end

  describe "Validations" do
    it { is_expected.to validate_uniqueness_of(:wallet_addr) }
    it { is_expected.to validate_uniqueness_of(:wallet_addr_downcased) }
  end

  describe "Indexes" do
    it { is_expected.to have_index_for(wallet_addr: 1).with_options(name: "wallet_addr_index", background: true, unique: true) }
    it { is_expected.to have_index_for(wallet_addr_downcased: 1).with_options(name: "wallet_addr_downcased_index", background: true, unique: true) }
    it { is_expected.to have_index_for(completed: 1).with_options(name: "completed_index", background: true) }
    it { is_expected.to have_index_for(wallet_addr: 1, "steps.name": 1).with_options(name: "wallet_addr_steps_name_index", unique: true, background: true) }
  end

  describe "Methods" do
    let(:tutorial_progress) do
      create(:tutorial_progress, completed: false) do |tutorial_progress|
        tutorial_progress.steps << build(:step, name: TutorialProgress::STEPS.first)
      end
    end

    it "checks if tutorial is completed" do
      expect(tutorial_progress.tutorial_completed?).to be(false)
    end

    it "checks if a step is already completed" do
      expect(tutorial_progress.step_completed?("cristiano_dos_steps")).to be(false)
    end

    it "checks if a step is already completed" do
      expect(tutorial_progress.step_completed?(TutorialProgress::STEPS.first)).to be(true)
    end
  end
end
