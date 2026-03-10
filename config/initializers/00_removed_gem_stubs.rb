# Stubs for gems removed from RealFevr that are no longer needed in PTCG Battle Arena.
# These prevent boot-time crashes from eager-loaded files that still reference these constants.
# Named 00_ so it runs before all other initializers.

# ── Kafka (fantasy-revolution-kafka-integration gem removed) ─────────────────
module KafkaIntegration
  class Consumer
    def self.inherited(subclass); end

    # No-op: consumers declare which Kafka topic they subscribe to.
    # Since we don't run Kafka, this is silently ignored at boot.
    def self.subscribes_to(topic, **opts)
      Rails.logger.debug("[KafkaIntegration] Stub: #{name} would subscribe to #{topic}") if defined?(Rails)
    end

    # No-op: consumer group id declaration
    def self.group_id=(id); end
    def self.group_id; nil; end
  end

  class Producer
    def self.deliver(payload, topic:, **opts)
      Rails.logger.debug("[KafkaIntegration] Stub: would deliver to #{topic}") if defined?(Rails)
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

    def call(contract, func, *args)
      nil
    end
  end

  # Stub for Eth::Contract — used in blockchain_consolidation services (not active in PTCG)
  class Contract
    def self.from_abi(name:, address:, abi:)
      new
    end

    def self.from_bin(name:, bin:, abi:)
      new
    end

    def functions
      []
    end
  end

  # Stub for Eth::Address — used in blockchain_consolidation services (not active in PTCG)
  class Address
    attr_reader :address

    def initialize(address)
      @address = address.to_s
    end

    def to_s
      @address
    end

    def checksummed
      @address
    end
  end
end

# ── RealfevrLibs Engine stub (routes.rb mounts RealfevrLibs::Engine) ─────────
# Provides a no-op engine so the mount call doesn't crash at boot.
module RealfevrLibs
  class Engine < Rails::Engine
  end
end

# ── Callable concern (realfevr_libs gem removed) ─────────────────────────────
# 15 service classes do `include Callable` to get a `MyService.call(...)` class
# method that delegates to `new(...).call`. This is the standard service object
# pattern. Recreated here so services load without the gem.
module Callable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # MyService.call(*args) → MyService.new(*args).call
    def call(*args, &block)
      new(*args, &block).call
    end
  end
end
