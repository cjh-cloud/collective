import knex from 'knex';
import { randomInt } from 'crypto';

const pg = knex({
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

const server = Bun.serve({
  port: 3000,
  async fetch(req) {

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
    var date = year + "-" + monthPadding + month + "-" + dayPadding + day

    console.log(date);
    var nextDay = new Date(date);
    nextDay.setDate(nextDay.getDate() + 1);
    const nextDayStr = nextDay.toJSON().split("T")[0]
    console.log(nextDayStr);

    // The type of usersQueryBuilder is determined here
    const usersQueryBuilder = pg
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

    return new Response(rides.toString());

    // return new Response("Bun!");
  },
});

console.log(`Listening on http://localhost:${server.port} ...`);
