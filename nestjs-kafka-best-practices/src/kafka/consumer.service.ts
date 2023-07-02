import { Injectable, OnApplicationShutdown } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Consumer, ConsumerRunConfig, ConsumerSubscribeTopics, Kafka } from "kafkajs";
import { DatabaseService } from "src/database/database.service";
import { IConsumer } from "./consumer.interface";
import { KafkajsConsumerOptions } from "./kafkajs-consumer-options.interface";
import { KafkajsConsumer } from "./kafkajs.consumer";

@Injectable()
export class ConsumerService implements OnApplicationShutdown {
    private readonly consumers: IConsumer[] = [];

    // env vars config service
    constructor(private readonly configService: ConfigService, private readonly databaseService: DatabaseService) { }

    async consume({ topic, config, onMessage }: KafkajsConsumerOptions) {
        const consumer = new KafkajsConsumer(
            topic,
            this.databaseService,
            config,
            this.configService.get('KAFKA_BROKER'),
        );
        await consumer.connect();
        await consumer.consume(onMessage);
        this.consumers.push(consumer); // push consumer to array of consumers so we can shut it down later
    }

    async onApplicationShutdown() {
        for (const consumer of this.consumers) {
            await consumer.disconnect();
        }
    }
}