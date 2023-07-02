import { ConsumerConfig, ConsumerSubscribeTopics, KafkaMessage } from "kafkajs";

export interface KafkajsConsumerOptions {
  topic: ConsumerSubscribeTopics;
  config: ConsumerConfig;
  onMessage: (message: KafkaMessage) => Promise<void>;
}