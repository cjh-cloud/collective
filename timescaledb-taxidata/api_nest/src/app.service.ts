import { Injectable } from '@nestjs/common';
import { randomInt } from 'crypto';
import knex from 'knex';

interface Ride {
  started_at: Date;
  ended_at: Date;
  distance: number;
  tip_amount: number;
  total_amount: number;
}

@Injectable()
export class AppService {
  pg = knex({
    client: 'pg',
    connection: {
      connectionString: "postgres://timescaledb:password@127.0.0.1:5433/timescaledb?sslmode=disable", //config.DATABASE_URL,
      host: "127.0.0.1", // config["DB_HOST"],
      port: 5433, // config["DB_PORT"],
      user: "timescaledb", // config["DB_USER"],
      database: "timescaledb", // config["DB_NAME"],
      password: "password", // config["DB_PASSWORD"],
      ssl: "disable", // config["DB_SSL"] ? { rejectUnauthorized: false } : false,
    }
  });

  async getHello(date: string): Promise<string> {

    const year = 2022 + randomInt(2)
    const month = 1 + randomInt(12)
    var monthPadding = ""
    if (month < 10) {
      monthPadding = "0"
    }
    const day = 1 + randomInt(28) // we'll miss 29,30,31 but oh well
    var dayPadding = ""
    if (day < 10) {
      dayPadding = "0"
    }
    date = year + "-" + monthPadding + month + "-" + dayPadding + day

    console.log(date);
    var nextDay = new Date(date);
    nextDay.setDate(nextDay.getDate() + 1);
    const nextDayStr = nextDay.toJSON().split("T")[0]
    console.log(nextDayStr);

    // The type of usersQueryBuilder is determined here
    const usersQueryBuilder = this.pg
      .select('*')
      .from('trips_hyper')
      .where('started_at', '>', date)
      .where('started_at', '<', nextDayStr)
      .limit(10);

    const rides = await usersQueryBuilder.then((rides) => {
      // Type of users here will be Pick<User, "id">[]
      // which may not be what you expect.
      // console.log(rides);
      return JSON.stringify(rides);
    });

    return rides.toString();

    // return 'Hello World!';
  }
}
