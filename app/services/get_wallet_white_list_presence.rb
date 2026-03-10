class GetWalletWhiteListPresence < ApplicationService
  def call(address, wl_name = Rails.application.config.white_list_name)
    wl_base_url = Rails.application.config.white_lists_api_base_url
    url = "#{wl_base_url}/white_lists/#{wl_name}/#{address}"
    headers = {"X-RealFevr-Token" => Rails.application.config.white_list_external_api_key}
    HTTParty.get(url, headers: headers)
  end
end
