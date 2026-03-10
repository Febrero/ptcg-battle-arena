require "rails_helper"

RSpec.describe ExportTicketOffersJob, type: :job do
  describe "#perform" do
    context "when run job" do
      it "service is called" do
        allow(ExportTicketOffers).to receive(:call).and_return("mail@realfevr.com")

        described_class.new.perform("mail@realfevr.com")
      end
    end
  end
end
