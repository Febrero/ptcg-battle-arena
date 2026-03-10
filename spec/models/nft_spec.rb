require "rails_helper"

RSpec.describe Nft, type: :model do
  describe "variables" do
    let(:nft_api_url) { URI.join Rails.application.config.realfevr_services[:marketplace][:service] }

    it "has element name: nft" do
      expect(Nft.element_name).to eq("nft")
    end

    it "has primary key: uid" do
      expect(Nft.primary_key).to eq("uid")
    end

    it "has site url" do
      expect(Nft.site).to eq(nft_api_url)
    end
  end
end
