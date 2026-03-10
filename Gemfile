source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6.8"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# mongodb
gem "mongoid", "~> 7.3.0"

# Serializers
gem "active_model_serializers"

# Pagination
gem "mongoid-pagination"

# Json serializers
gem "oj"
gem "oj_mimic_json"

# Error tracking
gem "airbrake"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors", require: "rack/cors"

# # API Doc generator
gem "apipie-rails"

# Support for mongoid migrations
gem "mongoid_rails_migrations"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# active resource
gem "activeresource"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"
gem "rest-client"

# Http requests
gem "httparty"

# Aplication monitoring
# gem "newrelic_rpm"

gem "json_api_client"

# Redis
gem "hiredis", "~> 0.6.0"
gem "redis", "~> 4.6.0", require: ["redis", "redis/connection/hiredis"]

# Background Jobs ecosystem
gem "sidekiq", "~> 7.1.4"
gem "sidekiq-failures"
gem "sidekiq-status"
gem "sidekiq-scheduler"

# Rabbitmq
gem "bunny"

gem "eth"

# Deployment scripts
gem "after_party"

# State machine
gem "aasm"

gem "nokogiri", ">= 1.16.2"

gem "mandrill_mailer"

# JWT for authentication
gem "jwt"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 5.0.0"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  # Stadard ruby syntax
  gem "standard", "~> 1.24.3"
end

group :test do
  gem "brakeman", "~> 5.4"
  gem "bundler-audit", "~> 0.9.1"
  gem "database_cleaner-mongoid"
  gem "factory_bot_rails"
  # Generate random values
  gem "faker", git: "https://github.com/faker-ruby/faker.git", branch: "main"
  gem "mongoid-rspec"
  gem "shoulda-matchers"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-formatter-badge", "~> 0.1.0", require: false
  # Mock and record http requests
  gem "vcr"
  gem "webmock"
  gem "rspec-sidekiq"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "solargraph", "~> 0.49.0"
  gem "rubocop", "~> 1.44.1"
  gem "yard", "~> 0.9.36"
end

group :production do
  gem "ddtrace", require: "ddtrace/auto_instrument"
end

# PTCG Battle Arena — private gems removed (RealFevr dependencies not needed)
