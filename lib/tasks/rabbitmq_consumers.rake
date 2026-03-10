namespace :rabbitmq do
  namespace :consumer do
    desc "Run Consumer"
    task :run, [:consumer_name] => :environment do |t, args|
      Rails.logger = Logger.new($stdout)
      $stdout.sync = true # Enable immediate flushing of STDOUT
      "Rabbitmq::#{args[:consumer_name]}".constantize.new.run
    end
  end
end
