# Stubs for gems removed from RealFevr that are no longer needed in PTCG Battle Arena.
# These prevent boot-time crashes from eager-loaded files that still reference these constants.
# Named 00_ so it runs before all other initializers.

# ── Kafka (fantasy-revolution-kafka-integration gem removed) ─────────────────
module KafkaIntegration
  class Consumer
    def self.inherited(subclass); end
  end

  class Producer
    def self.deliver(payload, topic:, **opts)
      Rails.logger.debug("[KafkaIntegration] Stub: would deliver to #{topic}")
    end
  end
end

# ── Eth (fantasy-revolution-web3 / eth gem removed) ──────────────────────────
module Eth
  module Abi
    module Event
      def self.decode_logs(interface, logs)
        []
      end
    end
  end

  class Client
    def self.create(endpoint)
      new
    end

    def eth_get_logs(_params)
      { "result" => [] }
    end
  end
end

# ── ActiveResource (used only in app/models/nft.rb for NFT API calls) ────────
# activeresource gem IS in Gemfile so this is fine — no stub needed.
