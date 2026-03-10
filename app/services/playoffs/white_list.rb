module Playoffs
  class WhiteList
    include Callable

    attr_reader :wallet_addr, :playoff_uid

    def initialize(playoff_uid, wallet_addr)
      @playoff_uid = playoff_uid
      @wallet_addr = wallet_addr.downcase
    end

    def call
      is_wallet_in_whitelist?
    end

    private

    def list_name
      "playoff-#{playoff_uid}"
    end

    def is_wallet_in_whitelist?
      InternalApi.new.get("whitelists", request_uri: "/white_lists/#{list_name}/#{wallet_addr}").response.code == 200
    rescue InternalApiNotFound
      false
    end
  end
end
