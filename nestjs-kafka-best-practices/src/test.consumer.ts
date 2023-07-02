// Topic name is called test which is why this is test.consumer.ts

import { Injectable, OnModuleInit } from "@nestjs/common";
import { ConsumerService } from "./kafka/consumer.service";

@Injectable()
export class TestConsumer implements OnModuleInit {
    constructor(private readonly consumerService: ConsumerService) { }

    async onModuleInit() {
        await this.consumerService.consume({
            topic: { topics: ['test'] },
            config: { groupId: 'test-consumer' },
            onMessage: async (message) => {
                console.log(message.value.toString());
                throw new Error('Test error!');
            },
        });
    }
}