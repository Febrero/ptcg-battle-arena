# frozen_string_literal: true

# spec/support/request_spec_helper
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    LoadPlayersFromCsv.call("imports/grey_cards_properties.csv", GreyCard, true)
    strategy = DatabaseCleaner::Mongoid::Deletion.new except: ["videos", "grey_cards"]
    DatabaseCleaner[:mongoid].instance_variable_set :@strategy, strategy
  end

  config.before do
    DatabaseCleaner[:mongoid].start
  end

  config.after do
    DatabaseCleaner[:mongoid].clean
  end

  config.after(:suite) do
    GreyCard.destroy_all
  end
end
