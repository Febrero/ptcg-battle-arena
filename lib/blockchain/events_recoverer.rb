module Blockchain
  class EventsRecoverer
    attr_reader :rpc_endpoint, :contract_address, :abi, :from_block, :to_block, :batch_size

    def initialize(rpc_endpoint, contract_address, abi, from_block = nil, to_block = nil, batch_size = 10)
      @rpc_endpoint = rpc_endpoint
      @contract_address = contract_address
      @abi = abi
      @from_block = from_block
      @to_block = to_block
      @batch_size = batch_size
    end

    def recover
      @from_block = contract_creation_block_number if from_block.nil?
      @to_block = latest_block_number if to_block.nil?

      (from_block..to_block).each_slice(batch_size) do |batch|
        puts "Recovering events from #{batch.first} to #{batch.last}"

        logs = client.eth_get_logs({
          address: contract_address,
          fromBlock: batch.first,
          toBlock: batch.last,
          topics: []
        })["result"]

        events_interface = abi.select { |item| item["type"] == "event" }

        events = Eth::Abi::Event.decode_logs(events_interface, logs)

        events.each do |event|
          yield(event) unless event.last.nil?
        end
      end
    end

    private

    def contract_creation_block_number
      lower = 0
      middle = nil
      upper = latest_block_number

      while lower <= upper
        middle = (lower + upper) / 2

        code = client.eth_get_code(contract_address, middle)["result"]

        if code != "0x"
          upper = middle - 1
        else
          lower = middle + 1
        end
      end

      lower
    end

    def latest_block_number
      client.eth_block_number["result"].to_i(16)
    end

    def client
      @client ||= Eth::Client.create(rpc_endpoint)
    end
  end
end
