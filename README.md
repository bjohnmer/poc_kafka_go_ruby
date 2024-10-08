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

## Arquitectura del Sistema

El sistema consta de un publicador y un suscriptor que se comunican a través de Kafka. A continuación se muestra un diagrama simplificado de la arquitectura:

```mermaid
graph LR
    A[Publicador] -->|Publica mensajes| B((Kafka))
    B -->|Consume mensajes| C1[Suscriptor 1]
    B -->|Consume mensajes| C2[Suscriptor 2]
    C1 -->|Escribe mensajes| D1[(Archivo de salida 1)]
    C2 -->|Escribe mensajes| D2[(Archivo de salida 2)]
```

### Flujo de datos:

1. El Publicador genera mensajes y los envía a un tema específico en Kafka.
2. Kafka actúa como intermediario, almacenando los mensajes publicados.
3. El Suscriptor se conecta a Kafka y consume los mensajes del tema especificado.
4. El Suscriptor escribe los mensajes recibidos en un archivo de salida.

Este diseño permite una comunicación asíncrona y desacoplada entre el publicador y el suscriptor, proporcionando escalabilidad y resistencia a fallos.

## Clona este repositorio:
```
git clone git@github.com:bjohnmer/poc_kafka_go_ruby.git
cd poc_kafka_go_ruby
```

## Arrancar contenedores

Este proyecto soporta múltiples arquitecturas (amd64 y arm64). Hay varias formas de ejecutar el proyecto dependiendo de tu arquitectura y preferencias.

### Opción 1: Detección automática de arquitectura

Puedes usar el script `run-docker-compose.sh` que detectará automáticamente la arquitectura de tu sistema y usará el Dockerfile apropiado.

1. Dale permisos de ejecución al script:
   ```
   chmod +x run-docker-compose.sh
   ```

2. Ejecuta el script:
   ```
   ./run-docker-compose.sh
   ```

### Opción 2: Especificar manualmente la arquitectura

Si prefieres especificar manualmente la arquitectura, puedes usar uno de los siguientes comandos:

Para arquitecturas AMD64 (x86_64):
```
DOCKERFILE=Dockerfile.amd64 docker-compose up --build -d
```

Para arquitecturas ARM64:
```
DOCKERFILE=Dockerfile.arm64 docker-compose up --build -d
```

### Opción 3: Usar el Dockerfile por defecto

Si no especificas un Dockerfile, se usará `Dockerfile.amd64` por defecto:

```
docker-compose up -d --build
```

Esto iniciará Zookeeper, Kafka, Kafdrop, el publicador y dos suscriptores.

## Instrucciones de ejecución

Una vez que los servicios estén en ejecución, puedes continuar con los siguientes pasos:

1. Cambia al directorio del publicador:
   ```
   cd publisher
   ```
2. Habilita la version de Go dependiendo de tu arquitectura:

   #### AMD64
   ```go
   go 1.23.1 // Para AMD64
   // go 1.20 // Para ARM64
   ```

   #### ARM64
   ```go
   // go 1.23.1 // Para AMD64
   go 1.20 // Para ARM64
   ```

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
