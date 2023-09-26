BEGIN;

CREATE TABLE IF NOT EXISTS trips (
  started_at TIMESTAMPTZ not null,
  ended_at TIMESTAMPTZ not null,
  distance float not null,
  tip_amount float,
  total_amount float,
  cab_type_id int not null
);

CREATE TABLE IF NOT EXISTS trips_hyper (
  started_at TIMESTAMPTZ not null,
  ended_at TIMESTAMPTZ not null,
  distance float not null,
  tip_amount float,
  total_amount float,
  cab_type_id int not null
);

SELECT create_hypertable('trips_hyper', 'started_at');

COMMIT;
