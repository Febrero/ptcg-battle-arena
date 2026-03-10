require "rails_helper"

RSpec.describe "V1::TicketBundles", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let!(:ticket_bundle) { create(:ticket_bundle) }

  describe "GET /v1/ticket_bundles" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/ticket_bundles", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/ticket_bundles"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /ticket_bundles" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/ticket_bundles", headers: headers, params: {
          data: {
            attributes: {
              name: "ticket bundle bla",
              slug: "ticket-bundle-bla",
              image_url: "https://google.com",
              tickets_quantity: 1,
              old_price: "0.1",
              discount: "0.1",
              final_price: "0.09",
              order: 1,
              sale_expiration_date: Time.now + 3.months,
              ticket_id: ticket_bundle.ticket.id
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/ticket_bundles", params: {
          data: {
            attributes: {
              name: "ticket bundle bla",
              slug: "ticket-bundle-bla",
              image_url: "https://google.com",
              tickets_quantity: 1,
              old_price: "0.1",
              discount: "0.1",
              final_price: "0.09",
              order: 1,
              sale_expiration_date: Time.now + 3.months,
              ticket_id: ticket_bundle.ticket.id
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/ticket_bundles/:id" do
    context "when authenticated" do
      before do
        put "/v1/ticket_bundles/#{ticket_bundle.id}", headers: headers, params: {
          data: {
            attributes: {
              name: "ticket bundle bl1",
              slug: "ticket-bundle-bla",
              image_url: "https://google.com",
              tickets_quantity: 1,
              old_price: "0.1",
              discount: "0.1",
              final_price: "0.09",
              order: 1,
              sale_expiration_date: Time.now + 3.months,
              ticket_id: ticket_bundle.ticket.id
            }
          }
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates name attribute" do
        expect(ticket_bundle.reload.name).to eq("ticket bundle bl1")
      end
    end
  end

  context "when not authenticated" do
    it "returns http forbidden" do
      put "/v1/ticket_bundles/#{ticket_bundle.id}", params: {
        data: {
          attributes: {
            name: "ticket bundle bla",
            slug: "ticket-bundle-bla",
            image_url: "https://google.com",
            tickets_quantity: 1,
            old_price: "0.1",
            discount: "0.1",
            final_price: "0.09",
            order: 1,
            sale_expiration_date: Time.now + 3.months,
            ticket_id: ticket_bundle.ticket.id
          }
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /v1/ticket_bundles" do
    context "when authenticated" do
      it "returns http success" do
        delete "/v1/ticket_bundles/#{ticket_bundle.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        delete "/v1/ticket_bundles/#{ticket_bundle.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
