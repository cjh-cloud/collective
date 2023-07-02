import { Injectable, OnApplicationShutdown, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Kafka, Message, Producer, ProducerRecord } from "kafkajs";
import { IProducer } from "./producer.interface";
import { KafkajsProducer } from "./kafkajs.producer";

// Don't need to implement OnModuleInit anymore
@Injectable()
export class ProducerService implements OnApplicationShutdown {
    private readonly producers = new Map<string, IProducer>();

    constructor(private readonly configService: ConfigService) { }

    // replaces OnModuleInit
    async produce(topic: string, message: Message) {
        const producer = await this.getProducer(topic);
        await producer.produce(message);
    }

    private async getProducer(topic: string) {
        let producer = this.producers.get(topic);

        // If producer doesn't already exist, create it
        if (!producer) {
            producer = new KafkajsProducer(topic, this.configService.get('KAFKA_BROKER'));
            await producer.connect();
            this.producers.set(topic, producer); // add to map
        }
        return producer;
    }

    async onApplicationShutdown() {
        for (const producer of this.producers.values()) {
            await producer.disconnect();
        }
    }
}