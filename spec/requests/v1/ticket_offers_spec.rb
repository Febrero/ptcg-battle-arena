require "rails_helper"

RSpec.describe "V1::TicketOffers", type: :request do
  let!(:ticket_offer) { create(:ticket_offer) }
  let!(:ticket) { create(:ticket) }
  let!(:ticket1) { create(:ticket) }

  let!(:headers_event_listener) do
    {"X-RealFevr-Auth" => Rails.application.config.auth_event_listener}
  end

  let!(:headers_internal_api) do
    {"X-RealFevr-I-Token" => Rails.application.config.internal_api_key}
  end

  describe "GET /v1/ticket_offers" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/ticket_offers", headers: headers_internal_api

        expect(response).to have_http_status(:success)
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        get "/v1/ticket_offers"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/ticket_offers" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/ticket_offers", headers: headers_internal_api, params: {
          data: {
            attributes: {
              wallet_addr: "0x123",
              quantity: 1,
              bc_ticket_id: ticket.bc_ticket_id,
              ticket_factory_contract_address: ticket.ticket_factory_contract_address
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/ticket_offers", params: {
          data: {
            attributes: {
              wallet_addr: "0x123",
              quantity: 1,
              bc_ticket_id: ticket.bc_ticket_id,
              ticket_factory_contract_address: ticket.ticket_factory_contract_address
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end

      it "returns http success" do
        post "/v1/ticket_offers", headers: headers_internal_api, params: {
          data: {
            attributes: {
              wallet_addr: "0x123",
              quantity: 1,
              bc_ticket_id: [ticket.bc_ticket_id, ticket1.bc_ticket_id],
              ticket_factory_contract_address: ticket.ticket_factory_contract_address
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http success" do
        post "/v1/ticket_offers", headers: headers_internal_api, params: {
          data: {
            attributes: {
              wallet_addr: "0x123",
              quantity: 1,
              bc_ticket_id: [ticket.bc_ticket_id, ticket1.bc_ticket_id]
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http success" do
        post "/v1/ticket_offers", headers: headers_internal_api, params: {
          data: {
            attributes: {
              wallet_addr: "0x123",
              quantity: 1,
              ticket_factory_contract_address: ticket.ticket_factory_contract_address
            }
          }
        }
        expect(response).to have_http_status(:success)
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        put "/v1/ticket_offers/#{ticket_offer.id}", params: {data: {attributes: {offered: true, tx_hash: "falsa"}}}

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/ticket_offers/:id" do
    context "when authenticated" do
      it "returns http success" do
        put "/v1/ticket_offers/#{ticket_offer.id}", params: {data: {attributes: {offered: true, tx_hash: "falsa"}}},
          headers: headers_internal_api

        expect(ticket_offer.reload.offered).to be_truthy
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        put "/v1/ticket_offers/#{ticket_offer.id}", params: {data: {attributes: {offered: true, tx_hash: "falsa"}}}

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/ticket_offers/export_csv" do
    context "when authenticated" do
      it "returns http success" do
        put "/v1/ticket_offers/export_csv", params: {email: "fake@fake.com"},
          headers: headers_internal_api

        expect(response).to have_http_status(:success)
      end
    end

    context "when unauthenticated" do
      it "returns http forbidden" do
        put "/v1/ticket_offers/export_csv", params: {email: "fake@fake.com"}

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
