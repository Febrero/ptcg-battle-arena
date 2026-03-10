require "rails_helper"

RSpec.describe TicketOffer, type: :model do
  subject(:ticket_offer) { described_class.new }

  describe "Associations" do
    it { is_expected.to belong_to(:ticket) }
  end
end
