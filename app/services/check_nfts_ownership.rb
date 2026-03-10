class CheckNftsOwnership < ApplicationService
  def call(wallet_addr, nft_uids)
    params = {
      wallet_addr: wallet_addr,
      nft_ids: nft_uids.join(",")
    }

    InternalApi.new.get("marketplace", request_uri: "/nfts/check_ownership", query: params)
  end
end
