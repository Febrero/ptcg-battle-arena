require "rails_helper"

RSpec.describe SurvivalPlayers::Entry, type: :model do
  subject { described_class.new }

  describe "fields" do
    it { is_expected.to have_timestamps }
  end

  describe "associations" do
    it { is_expected.to be_embedded_in(:survival_player) }
  end
end
