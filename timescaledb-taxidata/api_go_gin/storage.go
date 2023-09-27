package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

type Storage interface {
	GetTaxiRide() (*Ride, error)
}

type PostgresStore struct {
	db *sql.DB
}

func NewPostgresStore() (*PostgresStore, error) {
	godotenv.Load()
	connStr := fmt.Sprintf("host=%s port=%s user=%s dbname=%s password=%s sslmode=%s", 
		os.Getenv("HOST"), os.Getenv("DBPORT"), os.Getenv("DBUSER"), os.Getenv("DBNAME"), os.Getenv("DBPASS"), os.Getenv("SSLMODE"))

	// connStr := "host=127.0.0.1 port=5433 user=timescaledb dbname=timescaledb password=password sslmode=disable"

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(20)
	db.SetMaxIdleConns(20)

	// defer db.Close()

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return &PostgresStore {
		db: db,
	}, nil
}

func (s *PostgresStore) GetTaxiRide(date time.Time) ([]*Ride, error) {
	dateFormatted := date.Format("2006-01-02")
	nextDay := date.AddDate(0,0,1).Format("2006-01-02")
	// query := `SELECT * FROM trips_hyper WHERE started_at >= $1 AND started_at <= $2 LIMIT 10`
	query := "SELECT * FROM trips_hyper WHERE started_at >= '" + dateFormatted + "' AND started_at <= '" + nextDay + "' LIMIT 10"
	// query := "select 1;"

	// log.Println("Date: ", dateFormatted)
	// log.Println("Next: ", nextDay)
	log.Println("Query: ", query)

	// log.Println("Date: ", date.Format("2006-01-02"))
	// log.Println("Next: ", nextDay.Format("2006-01-02"))

	rows, err := s.db.Query(
		query,
		// dateFormatted,
		// nextDay,
	)
	if err != nil {
		return nil, err
	}

	// TODO : this is probably what's slow
	rides := []*Ride{}
	defer rows.Close()
	for rows.Next() {
		ride, err := scanIntoRide(rows)
		if err != nil {
			return nil, err
		}
		rides = append(rides, ride)
	}

	return rides, nil
}

func scanIntoRide(rows *sql.Rows) (*Ride, error) {
	ride := new(Ride)
	err := rows.Scan(
		&ride.StartedAt,
		&ride.EndedAt,
		&ride.Distance,
		&ride.TipAmount,
		&ride.TotalAmount,
		&ride.CabTypeId,
	)

	return ride, err
}
