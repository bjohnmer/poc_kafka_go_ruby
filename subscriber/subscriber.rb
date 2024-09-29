require 'kafka'
require 'fileutils'

instance = ENV['INSTANCE'] || 'default'
topic = "topic-#{instance}"
output_file = "/app/received_messages_#{instance}.txt"

FileUtils.touch(output_file)

def connect_with_retry(instance, max_retries = 5, retry_interval = 5)
  retries = 0
  begin
    kafka = Kafka.new(
      seed_brokers: [ENV['KAFKA_BROKER'] || 'kafka:9092'],
      client_id: instance,
      logger: Logger.new(File::NULL)
    )
    return kafka
  rescue Kafka::ConnectionError
    if retries < max_retries
      retries += 1
      sleep(retry_interval)
      retry
    else
      raise "No se pudo conectar a Kafka después de #{max_retries} intentos."
    end
  end
end

kafka = connect_with_retry(instance)

consumer = kafka.consumer(group_id: "#{instance}_group")
consumer.subscribe(topic, start_from_beginning: false)

File.open(output_file, 'a') do |file|
  file.puts("#{instance} listo para recibir mensajes...")
  
  consumer.each_message do |message|
    file.puts("#{instance} recibió: #{message.value}")
    file.flush  # Asegura que el mensaje se escriba inmediatamente
  end
end
