Apipie.configure do |config|
  config.app_name = "RealfevrBattleArenaApis"
  config.api_base_url = ""
  config.doc_base_url = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = [
    "#{Rails.root}/app/controllers/**/*.rb",
    "#{Auth::Engine.root}/app/controllers/**/*.rb" # Like this
  ]
  config.translate = false
  config.validate = :explicitly
  config.validate_value = false
  config.app_info = <<-DOC
    Welcome to RealfevrBattleArenaApi documentation.
  DOC
end
