// Migrations

import { ConfigService } from "@nestjs/config";
import { config } from "dotenv";
import { Comment } from "./src/items/entities/comments.entity";
import { Item } from "./src/items/entities/item.entity";
import { Listing } from "./src/items/entities/listing.entity";
import { Tag } from "./src/items/entities/tag.entity";
import { DataSource } from "typeorm";

config(); // will load .env from root

const configService = new ConfigService();

export default new DataSource({
  type: 'mysql',
  host: configService.getOrThrow('MYSQL_HOST'),
  port: configService.getOrThrow('MYSQL_PORT'),
  database: configService.getOrThrow('MYSQL_DATABASE'),
  username: configService.getOrThrow('MYSQL_USERNAME'),
  password: configService.getOrThrow('MYSQL_PASSWORD'),
  migrations: ['migrations/**'], // all migrations will live in folder
  // Have to manually load entites for some reason, unlike database.module.ts
  entities: [Item, Listing, Comment, Tag],
})