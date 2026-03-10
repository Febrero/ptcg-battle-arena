module NftsApi
  class Base < JsonApiClient::Resource
    self.site = Rails.application.config.nft_api_base_url

    DEFAULT_HEADERS = {"X-RealFevr-Token" => Rails.application.config.nfts_external_api_key}

    def self._header_store
      @_header_store ||= DEFAULT_HEADERS
    end
  end
end
