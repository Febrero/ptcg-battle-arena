require "rails_helper"

RSpec.describe Arena, type: :model do
  subject { described_class.new }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:total_prize_pool) }
    it { is_expected.to validate_presence_of(:rf_percentage) }
    it { is_expected.to validate_presence_of(:burn_percentage) }
    it { is_expected.to validate_presence_of(:possible_cashback_percentage) }
    it { is_expected.to validate_presence_of(:compatible_ticket_ids) }
    it { is_expected.to validate_presence_of(:active) }
  end
end
