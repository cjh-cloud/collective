import { Module } from '@nestjs/common';
import { DatabaseModule } from 'src/database/database.module';
import { ConsumerService } from './consumer.service';
import { ProducerService } from './producer.service';

@Module({
    imports: [DatabaseModule],
    providers: [ProducerService, ConsumerService], // not sure why here?
    exports: [ProducerService, ConsumerService], // so we can use it in our app
})
export class KafkaModule { }
