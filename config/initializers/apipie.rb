Apipie.configure do |config|
  config.app_name = "PTCGBattleArenaApis"
  config.api_base_url = ""
  config.doc_base_url = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = [
    "#{Rails.root}/app/controllers/**/*.rb"
  ]
  config.translate = false
  config.validate = :explicitly
  config.validate_value = false
  config.app_info = <<-DOC
    Welcome to PTCG Battle Arena API documentation.
  DOC
end
