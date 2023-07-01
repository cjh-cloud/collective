import { Inject, Injectable } from '@nestjs/common';
import { ClientKafka } from '@nestjs/microservices';
import { GetUserRequest } from './get-user-request.dto';
import { OrderCreatedEvent } from './order-created.event';

@Injectable()
export class AppService {
  constructor(
    @Inject('AUTH_SERVICE') private readonly authClient: ClientKafka,
  ) { }

  getHello(): string {
    return 'Hello World!';
  }

  handleOrderCreated(orderCreatedEvent: OrderCreatedEvent) {
    // console.log(orderCreatedEvent);
    // reach out to Auth client now
    this.authClient.send(
      'get_user',
      new GetUserRequest(orderCreatedEvent.userId),
    ).subscribe((user) => {
      console.log(
        `Billing user with stripe ID ${user.stripeUserId} a price of $${orderCreatedEvent.price}...`
      );
    }); // msg doesn't get sent without subscribe - will send msg to service and wait for reply back
  }
}
