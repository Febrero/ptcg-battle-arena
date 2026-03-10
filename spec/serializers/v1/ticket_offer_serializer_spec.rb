require "rails_helper"

RSpec.describe V1::TicketOfferSerializer, type: :serializer do
  let(:ticket) { create(:ticket, id: 1) }
  let(:ticket_offer) { create(:ticket_offer, ticket: ticket) }

  subject { V1::TicketOfferSerializer.new(ticket_offer).serializable_hash }

  describe "attributes" do
    it do
      expect(subject).to include(
        :ticket_id,
        :quantity,
        :wallet_addr,
        :offered,
        :tx_hash
      )
    end

    it "ticket offer attribute should return ticket_id" do
      expect(subject[:ticket_id]).to eq ticket_offer.ticket.bc_ticket_id
    end

    it "ticket offer attribute should return quantity" do
      expect(subject[:quantity]).to eq ticket_offer.quantity
    end

    it "ticket offer attribute should return wallet_addr" do
      expect(subject[:wallet_addr]).to eq ticket_offer.wallet_addr
    end

    it "ticket offer attribute should return offered" do
      expect(subject[:offered]).to eq ticket_offer.offered
    end

    it "ticket offer attribute should return tx_hash" do
      expect(subject[:tx_hash]).to eq ticket_offer.tx_hash
    end
  end
end
