class PublishMessageToRabbitmqTopic < ApplicationService
  def call(msg, topic, routing_key)
    connection = Rabbitmq::Base.new.connection
    connection.start
    channel = connection.create_channel
    exchange = channel.topic(topic)
    exchange.publish(msg, routing_key: routing_key)
    connection.close
  rescue => e
    Airbrake.notify(e)
  end
end
