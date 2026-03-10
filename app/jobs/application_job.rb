# frozen_string_literal: true

class ApplicationJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  # sidekiq_options
  # queue : use a named queue for this Worker, default 'default'
  # retry : enable the RetryJobs middleware for this Worker, default true. Alternatively, you can specify the max. number of times a job is retried (ie. retry: 3)
  # retry: 0 send directly to the dead queue.
  # backtrace : whether to save any error backtrace in the retry payload to display in web UI, can be true, false or an integer number of lines to save, default false. Be careful, backtraces are big and can take up a lot of space in Redis if you have a large number of retries.
  # pool : use the given Redis connection pool to push this type of job to a given shard.
  # dead: false # will retry 5 times and then disappear
  # Ex:
  # sidekiq_options retry: 10, queue: :critical, backtrace: true

  # Default Expoential backoff time-table for each retry: https://gist.github.com/marcotc/39b0d5e8100f0f4cd4d38eff9f09dcd5

  # MyWorker.perform_in(3.hours, 'mike', 1)
  # MyWorker.perform_at(3.hours.from_now, 'mike', 1)
  # MyWorker.perform_async("studs")

  # Tweek time to retry in

  # sidekiq_retry_in do |count|
  #   5
  # end

  def expiration
    @expiration ||= 1.hour.to_i
  end
end
