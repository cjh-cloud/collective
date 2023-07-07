import { Injectable, Logger } from '@nestjs/common';
import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';
import { Cron, CronExpression, SchedulerRegistry } from '@nestjs/schedule';
import { CreateUserRequest } from './dto/create-user.request';
import { UserCreatedEvent } from './events/user-created.event';

@Injectable()
export class AppService {
  constructor(
    private readonly eventEmitter: EventEmitter2,
    private schedulerRegistry: SchedulerRegistry // IN MEMORY, NOT DISTRIBUTED IF MULTIPLE PODS RUNNING
  ) { }

  private readonly logger = new Logger(AppService.name);

  getHello(): string {
    return 'Hello World!';
  }

  async createUser(body: CreateUserRequest) {
    this.logger.log('Creating user...', body);
    const userId = '123';
    this.eventEmitter.emit('user.created', new UserCreatedEvent(userId, body.email)) // event name, value to send to emitter
    const establishWsTimeout = setTimeout(() => this.establishWsConnection(userId), 5000);

    // to make sure timeout works after returning, schedule it
    this.schedulerRegistry.addTimeout(`${userId}_establish_ws`, establishWsTimeout)
  }

  private establishWsConnection(userId: string) {
    this.logger.log('Establishing WS connection with user...', userId);
  }

  @OnEvent('user.created')
  welcomeNewUser(payload: UserCreatedEvent) {
    this.logger.log('Welcoming new user...', payload.email);
  }

  @OnEvent('user.created', { async: true })
  async sendWelcomeGift(payload: UserCreatedEvent) {
    this.logger.log('Sending welcome gift...', payload.email);
    await new Promise<void>((resolve) => setTimeout(() => resolve(), 3000));
    this.logger.log('Welcome gift sent...', payload.email);
  }

  @Cron(CronExpression.EVERY_10_SECONDS, { name: 'delete_expired_users' }) // add name for schedulerRegistry
  deleteExpiredUsers() {
    this.logger.log('Deleting expired users...');
  }
}
