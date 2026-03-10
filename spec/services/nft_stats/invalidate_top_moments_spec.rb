require "rails_helper"

RSpec.describe NftStats::InvalidateTopMoments do
  describe "#call" do
    let(:wallet_addr) { "0x123" }

    it "updates the ownership last updated timestamp for the wallet address" do
      expect(TopMoments::NftStats).to receive(:update_ownership_last_updated_at).with(wallet_addr)
      NftStats::InvalidateTopMoments.call(wallet_addr)
    end
  end
end
