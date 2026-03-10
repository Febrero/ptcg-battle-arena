class FindContractCreationBlock < ApplicationService
  def call(contract_address)
    lower = 0
    middle = nil
    upper = block_number

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

  private

  def block_number
    Integer(client.eth_block_number["result"])
  end

  def client
    @client ||= Eth::Client.create(Rails.application.config.rpc_endpoint)
  end
end
