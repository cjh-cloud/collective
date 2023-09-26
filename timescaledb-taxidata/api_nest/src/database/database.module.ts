import { Module } from '@nestjs/common';
// import { ConfigService } from '@nestjs/config';
// import { TypeOrmModule } from '@nestjs/typeorm';
// import 'knex';

@Module({
  imports: [
    // TypeOrmModule.forRootAsync({
    //   useFactory: (configService: ConfigService) => ({
    //     type: 'postgres',
    //     host: configService.getOrThrow('POSTGRES_HOST'),
    //     port: configService.getOrThrow('POSTGRES_PORT'),
    //     database: configService.getOrThrow('POSTGRES_DB'),
    //     username: configService.getOrThrow('POSTGRES_USER'),
    //     password: configService.getOrThrow('POSTGRES_PASSWORD'),
    //     autoLoadEntities: true,
    //     synchronize: configService.getOrThrow('POSTGRES_SYNCHRONIZE'), // if we want TypeORM to create shcema
    //   }),
    //   inject: [ConfigService],
    // }),

    // require('knex')({
    //   client: 'pg',
    //   connection: {
    //     connectionString: "postgres://timescaledb:password@127.0.0.1:5433/timescaledb?sslmode=disable", //config.DATABASE_URL,
    //     host: "127.0.0.1", // config["DB_HOST"],
    //     port: 5433, // config["DB_PORT"],
    //     user: "timescaledb", // config["DB_USER"],
    //     database: "timescaledb", // config["DB_NAME"],
    //     password: "password", // config["DB_PASSWORD"],
    //     ssl: "disable", // config["DB_SSL"] ? { rejectUnauthorized: false } : false,
    //   }
    // }),
  ],
})
export class DatabaseModule { }
