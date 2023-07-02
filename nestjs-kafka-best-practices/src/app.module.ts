import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { KafkaModule } from './kafka/kafka.module';
import { TestConsumer } from './test.consumer';

@Module({
  imports: [
    KafkaModule,
    ConfigModule.forRoot({ isGlobal: true }), // reads in env file
  ],
  controllers: [AppController],
  providers: [AppService, TestConsumer],
})
export class AppModule { }
