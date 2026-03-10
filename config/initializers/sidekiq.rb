require "airbrake/sidekiq"

sidekiq_configs = YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result, permitted_classes: [Symbol])[Rails.env]["sidekiq"]
sidekiq_scheduler = YAML.load_file("#{Rails.root}/config/sidekiq_scheduler.yml", aliases: true)[Rails.env]
Rails.application.reloader.to_prepare do
  Sidekiq.schedule = sidekiq_scheduler
  SidekiqScheduler::Scheduler.instance.reload_schedule!
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_configs
  # config.redis = ConnectionPool.new(size: 100, &redis_conn)
  Sidekiq::Status.configure_client_middleware config, expiration: 1.hour
end

Sidekiq.configure_server do |config|
  config.redis = sidekiq_configs
  # config.redis = ConnectionPool.new(size: 100, &redis_conn)
  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 1.hour

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 1.hour
end

# By default, Airbrake notifies of all errors, including reoccurring errors during a retry attempt.
# To filter out these errors and only get notified when Sidekiq has exhausted its retries you can add the RetryableJobsFilter:
Airbrake.add_filter(Airbrake::Sidekiq::RetryableJobsFilter.new)
