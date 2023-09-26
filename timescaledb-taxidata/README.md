# TimescaleDB taxi data

This project contains supporting code for the TimescaleDB video on YouTube.

## Requirements

In order to use this project, you'll need to set up the following tools:

### TimescaleDB database

This project uses TimescaleDB as it's primary data store. There are a number
of ways to get a timescale DB instance up and running.

#### Timescale Managed

This is the easiest approach to get started, and it's free for 30 days. This
allows you to easily try timescale before commiting to any purchase or use case.

You can get the managed version of timescale on their [website](https://www.timescale.com/?utm_source=dreams-of-code&utm_medium=youtube&utm_campaign=kol-q3-2023&utm_content=homepage)

#### Timescale local

If you want to run it locally, you can do so by extending postgres. Timescale
have some great [documentation](https://docs.timescale.com/self-hosted/latest/install/)
on how to do that.

#### Timescale Docker

Finally, another great approach is to use docker. The
[documentation](https://docs.timescale.com/self-hosted/latest/install/installation-docker/)
providews instructions here as well. Be warned that if you're running docker
on a non linux machine, it will be slower due to having to run through a
hypervisor.

### Python3

Python3 is used as the primary language for downloading data and then
loading it into timescaleDB. The recommended version of python to use is
3.11.x or greater.

#### macOS

To install on macOS, one can use homebrew to do so using the following commands

```
$ brew install python
```

#### Arch Linux

```
$ sudo pacman -S python
```

### Debian

```
$ sudo apt install python
```

### psql

In the video we interact with the database using psql, which is a command line
tool provided by postgres.

#### macOS

To install it for macOS, you can use homebrew

```
$ brew install postgresql
```

or 

```
brew doctor
brew update
brew install libpq
brew link --force libpq
```
https://www.timescale.com/blog/how-to-install-psql-on-mac-ubuntu-debian-windows/

#### Arch Linux

```
$ sudo pacman -S postgresql
```

### migrate-cli

[migrate](https://github.com/golang-migrate/migrate) is used for database migrations. To install it, you can do so one of two
ways, depending on if you have go installed on your system or not.

#### Go

```
$ go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

#### macOS

```
$ brew install migrate
```

#### Arch Linux

```
$ yay -S migrate
```


### How to run

```
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install -r requirements.txt
$ python src/download.py
$ docker compose up
$ psql -U timescaledb -a -f migrations/001_trip_tables.up.sql -h 127.0.0.1 -p 5433
$ make migrate-hypertable
$ python src/load.py
$ make migrate-aggregate
```

SQL commands
```
select time_bucket(INTERVAL '1 month', bucket) AS month, AVG(avg), MAX(max), MIN(min) FROM total_summary_daily WHERE bucket >= '2022-01-01' AND bucket < '2023-01-01' GROUP BY bucket;
```

# Performance Testing

## Go Fiber API
```
cd api_go
make run
```

## Node.js Nestjs API

## Plow Performance Test
`plow http://127.0.0.1:3000/2022-03-07 -c 20 -n 100000`

Nest seems to handle 3x the requests as the Go Fiber API, at around 3000ps, and latency around 6ms:
Min 2-3ms
Mean 6ms
Max 30ms

Go Api
Min 1-2ms
Mean 20ms
Max 120ms-150ms

I would have expected Go to be much faster, maybe Nest or Knex was handling pg connections better?
