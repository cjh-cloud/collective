import { Logger } from "@nestjs/common";
import { Consumer, ConsumerConfig, ConsumerSubscribeTopics, Kafka, KafkaMessage } from "kafkajs";
import * as retry from "async-retry";
import { sleep } from "src/sleep";
import { IConsumer } from "./consumer.interface";
import { DatabaseService } from "src/database/database.service";

// More specific implementation of our consumer interface
export class KafkajsConsumer implements IConsumer {
  private readonly kafka: Kafka;
  private readonly consumer: Consumer;
  private readonly logger: Logger;

  constructor(
    private readonly topic: ConsumerSubscribeTopics, // ConsumerSubscribeTopic deprecated
    private readonly databaseService: DatabaseService,
    config: ConsumerConfig,
    broker: string,
  ) {
    this.kafka = new Kafka({ brokers: [broker] });
    this.consumer = this.kafka.consumer(config);
    this.logger = new Logger(`${topic.topics}-${config.groupId}`);
  }

  async connect() {
    try {
      await this.consumer.connect();
    } catch (err) {
      this.logger.error('Failed to connect to Kafka.', err);
      await sleep(5000);
      await this.connect(); // Try connect again, recursive
    }
  }

  async consume(onMessage: (message: KafkaMessage) => Promise<void>) {
    await this.consumer.subscribe(this.topic);

    // run will actually run our code when we receivce a new message
    await this.consumer.run({
      eachMessage: async ({ message, partition }) => {
        this.logger.debug(`Processing message partition: ${partition}`);
        // await onMessage(message);
        // retry 3 times, then could persist to dead letter queue
        try {
          await retry(async () => onMessage(message), {
            retries: 3,
            onRetry: (error, attempt) =>
              this.logger.error(
                `Error consuming message, executing retry ${attempt}/3`,
                error,
              ),
          });
        } catch (err) {
          this.logger.error('Error consuming message. Adding to DLQ...', err);
          await this.addMessageToDlq(message);
        }
      }
    })
  }

  private async addMessageToDlq(message: KafkaMessage) {
    await this.databaseService
      .getDbHandle()
      .collection('dlq')
      .insertOne({ value: message.value, topic: this.topic.topics });
  }

  async disconnect() {
    await this.consumer.disconnect();
  }
}