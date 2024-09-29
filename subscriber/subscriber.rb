# Required libraries
require 'kafka'
require 'fileutils'

# Set instance name and topic
instance = ENV['INSTANCE'] || 'default'
topic = "topic-#{instance}"
output_file = "/app/received_messages_#{instance}.txt"

# Ensure the output file exists
FileUtils.touch(output_file)

# Method to connect to Kafka with retry mechanism
def connect_with_retry(instance, max_retries = 5, retry_interval = 5)
  retries = 0
  begin
    # Attempt to create a Kafka client
    kafka = Kafka.new(
      seed_brokers: [ENV['KAFKA_BROKER'] || 'kafka:9092'],
      client_id: instance,
      logger: Logger.new(File::NULL)
    )
    return kafka
  rescue Kafka::ConnectionError
    # Retry logic if connection fails
    if retries < max_retries
      retries += 1
      sleep(retry_interval)
      retry
    else
      raise "Could not connect to Kafka after #{max_retries} attempts."
    end
  end
end

# Connect to Kafka
kafka = connect_with_retry(instance)

# Create a Kafka consumer
consumer = kafka.consumer(group_id: "#{instance}_group")
consumer.subscribe(topic, start_from_beginning: false)

# Open the output file and start consuming messages
File.open(output_file, 'a') do |file|
  file.puts("#{instance} ready to receive messages...")
  
  # Continuously consume messages
  consumer.each_message do |message|
    file.puts("#{instance} received: #{message.value}")
    file.flush  # Ensure the message is written immediately
  end
end
