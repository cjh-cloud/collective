package main

import (
	"database/sql"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

type Storage interface {
	GetTaxiRide() (*Ride, error)

	GetLatestFlight(time.Time) (*Flight, error)
	CreateFlight(*Flight) error
	GetStatusId(string) (*Status, error)
	GetFlights([]*Flight) error
	GetSchedules(string) ([]*Schedule, error)
}

type PostgresStore struct {
	db *sql.DB
}

func NewPostgresStore() (*PostgresStore, error) {
	godotenv.Load()
	connStr := fmt.Sprintf("host=%s port=%s user=%s dbname=%s password=%s sslmode=%s", 
		os.Getenv("HOST"), os.Getenv("PORT"), os.Getenv("DBUSER"), os.Getenv("DBNAME"), os.Getenv("DBPASS"), os.Getenv("SSLMODE"))

	// connStr := "host=127.0.0.1 port=5433 user=timescaledb dbname=timescaledb password=password sslmode=disable"

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return &PostgresStore {
		db: db,
	}, nil
}

func (s *PostgresStore) GetTaxiRide(date time.Time) ([]*Ride, error) {
	// dateFormatted := date.Format("2006-01-02")
	// nextDay := date.AddDate(0,0,1).Format("2006-01-02")
	// query := `SELECT * FROM trips_hyper WHERE started_at >= $1 AND started_at <= $2 LIMIT 10`
	// query := "SELECT * FROM trips_hyper WHERE started_at >= '" + dateFormatted + "' AND started_at <= '" + nextDay + "' LIMIT 10"
	query := "select 1;"

	// log.Println("Date: ", dateFormatted)
	// log.Println("Next: ", nextDay)
	// log.Println("Query: ", query)

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
	rows.Close()
	// for rows.Next() {
	// 	ride, err := scanIntoRide(rows)
	// 	if err != nil {
	// 		return nil, err
	// 	}
	// 	rides = append(rides, ride)
	// }

	return rides, nil
}

func (s *PostgresStore) GetLatestFlight() (*Flight, error) {
	query := "SELECT * FROM flight ORDER BY id DESC LIMIT 1";

	rows, err := s.db.Query(query)

	if err != nil {
		return nil, err
	}

	for rows.Next() {
		return scanIntoFlight(rows)
	}

	return nil, fmt.Errorf("latest flight not found")
}

// Had to double quote all columns to preserve uppercase in column names
func (s *PostgresStore) CreateFlight(flight *Flight) error {
	query := `INSERT INTO flight
	("estimatedDepartureTime", "actualDepartureTime", "flightDate", "display", "flightScheduleId", "statusId")
	values ($1, $2, $3, $4, $5, $6)`

	_, err := s.db.Query(
		query,
		flight.EstimatedDepartureTime,
		nil, // actual is null at this point
		flight.FlightDate.Format("2006-01-02"), // Format to get rid of the time
		flight.Display,
		flight.FlightScheduleId,
		flight.StatusId,
	)

	if err != nil {
		return err
	}

	// fmt.Printf("%+v\n", resp) // TODO

	return nil
}

// Take in string, and return id for that status
func (s *PostgresStore) GetStatusId(name string) (*Status, error) {
	rows, err := s.db.Query("SELECT * FROM status WHERE name = $1", name)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		return scanIntoStatus(rows)
	}

	return nil, fmt.Errorf("Status '%s' not found", name)
}

func (s *PostgresStore) GetDaySchedules(flightDate time.Time) ([]*Schedule, error) {
	day := strings.ToLower(
		flightDate.Weekday().String(),
	)

	rows, err := s.db.Query("SELECT * FROM flight_schedule WHERE " + day + " = true")
	if err != nil {
		return nil, err
	}

	schedules := []*Schedule{}
	for rows.Next() {
		schedule, err := scanIntoSchedule(rows)
		if err != nil {
			return nil, err
		}
		schedules = append(schedules, schedule)
	}

	return schedules, nil
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

func scanIntoFlight(rows *sql.Rows) (*Flight, error) {
	flight := new(Flight)
	err := rows.Scan(
		&flight.ID, 
		&flight.EstimatedDepartureTime, 
		&flight.ActualDepartureTime,
		&flight.FlightDate, 
		&flight.Display, 
		&flight.FlightScheduleId,
		&flight.StatusId)

	return flight, err
}

func scanIntoStatus(rows *sql.Rows) (*Status, error) {
	status := new(Status)
	err := rows.Scan(
		&status.ID, 
		&status.Name)

	return status, err
}

func scanIntoSchedule(rows *sql.Rows) (*Schedule, error) {
	schedule := new(Schedule)
	err := rows.Scan(
		&schedule.ID,
		&schedule.FlightNumber,
		&schedule.Origin,
		&schedule.Destination,
		&schedule.ScheduleDepartureTime,
		&schedule.Domestic,
		&schedule.Monday,
		&schedule.Tuesday,
		&schedule.Wednesday,
		&schedule.Thursday,
		&schedule.Friday,
		&schedule.Saturday,
		&schedule.Sunday,
		&schedule.AirlineId)

	return schedule, err
}
