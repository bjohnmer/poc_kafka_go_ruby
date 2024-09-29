# Proyecto de Publicador-Suscriptor con Kafka

Este proyecto demuestra un sistema simple de publicador-suscriptor utilizando Apache Kafka, con un publicador en Go y suscriptores en Ruby.

## Requisitos previos

- Docker
- Docker Compose

No se necesitan otras dependencias del sistema, ya que todo se ejecuta dentro de contenedores Docker.

## Estructura del proyecto

```
poc_kafka_go_ruby/
├── docker-compose.yml
├── publisher/
│   ├── Dockerfile
│   ├── main.go
│   └── go.mod
├── subscriber/
│   ├── Dockerfile
│   ├── subscriber.rb
│   └── Gemfile
└── README.md
```

## Instrucciones de ejecución

1. Clona este repositorio:
   ```
   git clone <URL_DEL_REPOSITORIO>
   cd poc_kafka_go_ruby
   ```

2. Inicia los servicios con Docker Compose:
   ```
   docker-compose up -d --build
   ```

   Esto iniciará Zookeeper, Kafka, Kafdrop, el publicador y dos suscriptores.

3. Verifica que todos los servicios estén en ejecución:
   ```
   docker-compose ps
   ```

   Deberías ver todos los servicios en estado "Up".

4. Para ejecutar el publicador y enviar mensajes:
   ```
   docker-compose exec publisher ./publisher
   ```

   Sigue las instrucciones en pantalla para enviar mensajes a los suscriptores.

5. Para verificar la recepción de mensajes en los suscriptores, puedes revisar los archivos de salida:

   Para el subscriber1:
   ```
   docker exec -it poc_kafka_go_ruby_subscriber1_1 cat /app/received_messages_subscriber1.txt
   ```

   Para el subscriber2:
   ```
   docker exec -it poc_kafka_go_ruby_subscriber2_1 cat /app/received_messages_subscriber2.txt
   ```

   Nota: Reemplaza `poc_kafka_go_ruby_subscriber1_1` y `poc_kafka_go_ruby_subscriber2_1` con los nombres reales de tus contenedores si son diferentes.

6. Para ver los mensajes en tiempo real a medida que llegan:

   Para el subscriber1:
   ```
   docker exec -it poc_kafka_go_ruby_subscriber1_1 tail -f /app/received_messages_subscriber1.txt
   ```

   Para el subscriber2:
   ```
   docker exec -it poc_kafka_go_ruby_subscriber2_1 tail -f /app/received_messages_subscriber2.txt
   ```

## Detener el proyecto

Para detener y eliminar todos los contenedores:
```
docker-compose down
```

## Solución de problemas

- Si los mensajes no aparecen en los archivos de los suscriptores, asegúrate de que el publicador esté enviando mensajes correctamente.
- Verifica los logs de Kafka si hay problemas de conexión:
  ```
  docker-compose logs kafka
  ```
- Si necesitas reconstruir los contenedores después de hacer cambios:
  ```
  docker-compose up --build -d
  ```
- Si tienes problemas para visualizar los tópicos en Kafdrop, verifica que el servicio esté en ejecución con `docker-compose ps` y revisa sus logs con `docker-compose logs kafdrop`

## Notas adicionales

- Este es un proyecto de demostración y no está destinado para uso en producción sin modificaciones adicionales.
- Asegúrate de tener suficiente espacio en disco y que los puertos necesarios (especialmente 9092 para Kafka) no estén en uso por otras aplicaciones.

## Monitoreo con Kafdrop

Este proyecto incluye Kafdrop, una interfaz web para visualizar y monitorear tus tópicos de Kafka. Para acceder a Kafdrop:

1. Asegúrate de que todos los servicios estén en ejecución usando el comando:
   ```
   docker-compose ps
   ```

2. Abre un navegador web y visita:
   ```
   http://localhost:9000
   ```

3. En la interfaz de Kafdrop, podrás ver:
   - Lista de tópicos
   - Detalles de cada tópico, incluyendo particiones y mensajes
   - Información sobre los grupos de consumidores

4. Para ver los mensajes en un tópico específico:
   - Haz clic en el nombre del tópico (por ejemplo, "topic-subscriber1" o "topic-subscriber2")
   - Selecciona la partición que deseas ver
   - Haz clic en "View Messages" para ver los mensajes más recientes

5. Puedes usar Kafdrop para:
   - Verificar que los mensajes se estén publicando correctamente
   - Monitorear el consumo de mensajes por parte de los suscriptores
   - Diagnosticar problemas en la comunicación entre el publicador y los suscriptores

Nota: Kafdrop es una herramienta de monitoreo y no debe usarse para modificar la configuración de Kafka en un entorno de producción.
