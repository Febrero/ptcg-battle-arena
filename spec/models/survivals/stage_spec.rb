require "rails_helper"

RSpec.describe Survivals::Stage, type: :model do
  subject { described_class.new }

  describe "fields" do
    it { is_expected.not_to have_timestamps }
  end

  describe "associations" do
    it { is_expected.to be_embedded_in(:survival) }
  end
end
