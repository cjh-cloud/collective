// Event subscriptions using TypeORM
// Allow us to listen to a number of different events to our data and tables
// and respond to them programatically

// List of events we can subscribe to
// https://typeorm.io/listeners-and-subscribers#what-is-a-subscriber

import { Logger } from "@nestjs/common";
import { DataSource, EntitySubscriberInterface, EventSubscriber, InsertEvent } from "typeorm";
import { Item } from "./entities/item.entity";

@EventSubscriber()
export class ItemSubscriber implements EntitySubscriberInterface<Item> {
  private readonly logger = new Logger(ItemSubscriber.name);

  constructor(dataSource: DataSource) {
    dataSource.subscribers.push(this);
  }

  listenTo(): string | Function {
    return Item;
  }

  beforeInsert(event: InsertEvent<Item>): void | Promise<any> {
    this.logger.log(`beforeInsert`, JSON.stringify(event.entity));
  }

  afterInsert(event: InsertEvent<Item>): void | Promise<any> {
    this.logger.log(`afterInsert`, JSON.stringify(event.entity));
  }
}