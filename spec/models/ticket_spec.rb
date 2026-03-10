require "rails_helper"

RSpec.describe Ticket, type: :model do
  subject(:ticket) { described_class.new }

  describe "Validations" do
    it { is_expected.to validate_presence_of(:bc_ticket_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:base_price) }
    it { is_expected.to validate_presence_of(:expiration_date) }
    it { is_expected.to validate_presence_of(:sale_expiration_date) }
    it { is_expected.to validate_presence_of(:available_quantities) }
    it { is_expected.to have_index_for(bc_ticket_id: 1, ticket_factory_contract_address: 1).with_options(unique: true, name: "bc_ticket_id_ticket_factory_contract_address_index", background: true) }
  end
end
