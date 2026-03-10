require "rails_helper"

RSpec.describe "V1::SplashScreens", type: :request do
  let!(:headers) do
    {"X-RealFevr-I-Token": Rails.application.config.internal_api_key}
  end
  let!(:splash_screen) { create(:splash_screen, name: "Screen X") }

  describe "GET /v1/splash_screens" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/splash_screens", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/splash_screens"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/splash_screens" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/splash_screens", headers: headers, params: {
          data: {
            attributes: {
              name: "Screen Y",
              image_url: "john wick",
              active: true
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/splash_screens", params: {
          data: {
            attributes: {
              name: "Screen Y",
              image_url: "john wick",
              active: true
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/splash_screens/:id" do
    context "when authenticated" do
      before do
        put "/v1/splash_screens/#{splash_screen.id}", headers: headers, params: {
          data: {
            attributes: {
              name: "John wick com as suas pistolas",
              image_url: "http://image_url",
              active: false
            }
          }
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates name attribute" do
        expect(splash_screen.reload.name).to eq("John wick com as suas pistolas")
      end
    end
  end

  context "when not authenticated" do
    it "returns http forbidden" do
      put "/v1/splash_screens/#{splash_screen.id}", params: {
        data: {
          attributes: {
            name: "John wick com as suas pistolas",
            image_url: "http://image_url",
            active: false
          }
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /v1/splash_screens/:id" do
    context "when authenticated" do
      it "returns http success" do
        delete "/v1/splash_screens/#{splash_screen.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        delete "/v1/splash_screens/#{splash_screen.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
