import { Controller, Get, Inject, OnModuleInit } from '@nestjs/common';
import { ClientKafka, EventPattern } from '@nestjs/microservices';
import { AppService } from './app.service';

@Controller()
export class AppController implements OnModuleInit {
  constructor(
    private readonly appService: AppService,
    @Inject('AUTH_SERVICE') private readonly authClient: ClientKafka,
  ) { }

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @EventPattern('order_created') // takes in pattern of the topic name
  handleOrderCreated(data: any) {
    this.appService.handleOrderCreated(data); // data.value didn't work
  }

  // Required for kafka reply with Auth microservice
  onModuleInit() {
    // topic billing sends message to auth service - reply topic will be get_user.reply
    this.authClient.subscribeToResponseOf('get_user');
  }
}
