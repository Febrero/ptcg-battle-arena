module BlockchainTransactionsUtils
  module_function

  def is_marketplace_transaction?(from, to)
    marketplaces = Rails.application.config.marketplace_contracts.map { |c| c[:contract_addr].downcase }

    marketplaces.include?(to.downcase) || marketplaces.include?(from.downcase)
  end

  def is_bridge_transaction?(from, to)
    bridges_contracts = Rails.application.config.bridges_contracts.map { |c| c[:contract_addr].downcase }
    bridges_contracts.include?(to.downcase) || bridges_contracts.include?(from.downcase)
  end

  def is_mint_transaction?(from)
    from.downcase === "0x0000000000000000000000000000000000000000"
  end
end
