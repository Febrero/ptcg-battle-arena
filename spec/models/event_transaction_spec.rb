require "rails_helper"

RSpec.describe EventTransaction, type: :model do
  subject { described_class.new }

  describe "Validations" do
    it { is_expected.to have_index_for(tx_hash: 1, log_index: 1).with_options(unique: true, background: true) }
    it { is_expected.to have_index_for(block_number: 1).with_options(name: "block_number_index", background: true) }
    it { is_expected.to validate_uniqueness_of(:tx_hash).scoped_to(:log_index).case_insensitive }
  end
end
