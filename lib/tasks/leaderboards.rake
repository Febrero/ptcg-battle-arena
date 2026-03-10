namespace :leaderboards do
  desc 'Reprocess the game for leaderboard purposes'
  task :reprocess_game, [:game_id] => :environment do |t, args|
    game = Game.find_by(game_id: args[:game_id])

    SendGameEventToKafka.call(game.to_original_request)
  end
end
