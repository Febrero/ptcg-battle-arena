require "rails_helper"

RSpec.describe Season, type: :model do
  subject { described_class.new }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to have_index_for(uid: 1).with_options(unique: true, name: "uid_index", background: true) }
  end
end
