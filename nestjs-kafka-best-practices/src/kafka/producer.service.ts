import { Injectable, OnApplicationShutdown, OnModuleInit } from "@nestjs/common";
import { Kafka, Producer, ProducerRecord } from "kafkajs";

@Injectable()
export class ProducerService implements OnModuleInit, OnApplicationShutdown {
    private readonly kafka = new Kafka({
        brokers: ['localhost:9092', '172.24.0.2:9092'],
    });
    private readonly producer: Producer = this.kafka.producer();

    // bootstrap?
    async onModuleInit() {
        await this.producer.connect(); // connect the producer to our server
    }

    async produce(record: ProducerRecord) {
        await this.producer.send(record);
    }

    async onApplicationShutdown() {
        await this.producer.disconnect();
    }
}