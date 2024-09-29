package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/confluentinc/confluent-kafka-go/kafka"
)

func main() {
	p, err := kafka.NewProducer(&kafka.ConfigMap{
		"bootstrap.servers": "kafka:9092",
		"acks":              "all",
	})
	if err != nil {
		panic(err)
	}
	defer p.Close()

	// Manejo de eventos de entrega
	go func() {
		for e := range p.Events() {
			switch ev := e.(type) {
			case *kafka.Message:
				if ev.TopicPartition.Error != nil {
					fmt.Printf("Error al entregar mensaje: %v\n", ev.TopicPartition.Error)
				} else {
					fmt.Printf("Mensaje entregado a %v\n", ev.TopicPartition)
				}
			}
		}
	}()

	fmt.Println("Publisher iniciado. Esperando entrada...")

	for {
		fmt.Print("Ingrese el mensaje y el subscriber (1 o 2): ")
		reader := bufio.NewReader(os.Stdin)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		parts := strings.SplitN(input, ",", 2)
		if len(parts) != 2 {
			fmt.Println("Formato incorrecto. Use: mensaje,1 o mensaje,2")
			continue
		}

		message, subscriberNum := parts[0], parts[1]
		topic := fmt.Sprintf("topic-subscriber%s", subscriberNum)

		fmt.Printf("Intentando enviar mensaje '%s' al tópico '%s'\n", message, topic)

		err := p.Produce(&kafka.Message{
			TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
			Value:          []byte(message),
		}, nil)

		if err != nil {
			fmt.Printf("Error al producir mensaje: %v\n", err)
		} else {
			fmt.Printf("Mensaje enviado a Kafka (pendiente de confirmación)\n")
		}

		// Esperar a que se entreguen todos los mensajes
		p.Flush(15 * 1000)
	}
}
