require "rails_helper"

RSpec.describe Events::SmartContracts::Opener::Transfer, vcr: true do
  let(:event) do
    ActiveSupport::HashWithIndifferentAccess.new({
      token_id: 4,
      from: "0x6c2005f258d8d1ef92d0a1e86b68e884d1808fb2",
      to: "0x0000000000000000000000000000000000012345"
    })
  end
  let!(:deck1) do
    create(:deck, nft_ids: (1..50).to_a, wallet_addr: "0x6c2005f258d8d1ef92d0a1e86b68e884d1808fb2")
  end

  it "removes nft from decks" do
    described_class.call(event)

    expect(deck1.reload.nft_ids).not_to include(4)
  end
end
