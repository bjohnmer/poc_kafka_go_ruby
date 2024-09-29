FROM golang:1.23.1

WORKDIR /app

# Copiar todos los archivos del proyecto
COPY . .

# Descargar dependencias, verificar y limpiar el módulo
RUN go mod download && \
    go mod verify && \
    go mod tidy

# Construir la aplicación
RUN go build -o publisher

CMD ["./publisher"]
