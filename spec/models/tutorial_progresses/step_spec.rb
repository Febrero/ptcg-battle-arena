require "rails_helper"

RSpec.describe TutorialProgresses::Step, type: :model do
  subject { described_class.new }

  describe "fields" do
    it { is_expected.to have_timestamps }
  end

  describe "associations" do
    it { is_expected.to be_embedded_in(:tutorial_progress) }
  end
end
