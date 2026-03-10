require "#{Rails.root}/lib/activeresource_enhancements.rb"
require "#{Rails.root}/lib/exceptions/leaderboard_source_not_available.rb"
require "#{Rails.root}/lib/exceptions/request_not_found.rb"
require "#{Rails.root}/lib/exceptions/request_timeout.rb"
require "#{Rails.root}/lib/exceptions/game_already_processed.rb"
require "#{Rails.root}/lib/exceptions/survivals/game_already_processed.rb"
require "#{Rails.root}/lib/exceptions/survivals/multiple_active_streak.rb"
require "#{Rails.root}/lib/exceptions/survivals/player_fields_missing.rb"
require "#{Rails.root}/lib/exceptions/survivals/entry_not_found.rb"
require "#{Rails.root}/lib/exceptions/survivals/ticket_not_spent.rb"
require "#{Rails.root}/lib/exceptions/not_enough_tickets_to_offer.rb"
require "#{Rails.root}/lib/exceptions/ticket_not_found.rb"
require "#{Rails.root}/lib/exceptions/invalid_card_offer_params.rb"

Dir["#{Rails.root}/lib/tasks/deployment/scripts/*.rb"].sort.each do |file|
  require file
end

require "#{Rails.root}/lib/user_activities/event_handler.rb"
require "#{Rails.root}/lib/user_activities/event_handlers/prizes/base.rb"
require "#{Rails.root}/lib/user_activities/event_handlers/rewards/base.rb"
Dir["#{Rails.root}/lib/user_activities/event_handlers/**/*.rb"].each do |file|
  require file
end

require "#{Rails.root}/lib/playoffs/drawer.rb"
require "#{Rails.root}/lib/playoffs/playoff_simulator.rb"
require "#{Rails.root}/lib/exceptions/playoffs/missing_game_for_round_advance.rb"
require "#{Rails.root}/lib/exceptions/playoffs/min_max_playoff_teams.rb"
require "#{Rails.root}/lib/field_enumerable.rb"

require "#{Rails.root}/lib/exceptions/playoffs/team_not_in_playoff.rb"
require "#{Rails.root}/lib/exceptions/playoffs/no_current_bracket.rb"
require "#{Rails.root}/lib/exceptions/playoffs/unrecognized_playoff_state_event.rb"

# blockchain/events_recoverer.rb removed — Web3/ETH not used in PTCG Battle Arena

require "#{Rails.root}/lib/importers/csv/grey_card_stats.rb"
require "#{Rails.root}/lib/assisted_gamers_importer.rb"
