package main

import (
	"log"
	"math/rand"
	"strconv"
	"time"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
)

func main() {
	// app := fiber.New()
	app := fiber.New(fiber.Config{
			JSONEncoder: json.Marshal,
			JSONDecoder: json.Unmarshal,
	})

	store, err := NewPostgresStore()
	if err != nil {
		log.Fatal(err)
	}

	app.Get("/:date", func(c *fiber.Ctx) error {

		//! Makes a new pg connection on request, and runs out of connections
		// store, err := NewPostgresStore()
		// if err != nil {
		// 	log.Fatal(err)
		// }

		// dateParam := c.Params("date")

		// ! randomise date instead, for perf testing
		// TODO - put this in func, and set dateParam based on ENV VAR for perf testing
		year := strconv.Itoa(2022 + rand.Intn(2))
		month := 1 + rand.Intn(12)
		monthPadding := ""
		if month < 10 {
			monthPadding = "0"
		}
		day := 1 + rand.Intn(28) // we'll miss 29,30,31 but oh well
		dayPadding := ""
		if day < 10 {
			dayPadding = "0"
		}
		dateParam := year + "-" + monthPadding + strconv.Itoa(month) + "-" + dayPadding + strconv.Itoa(day)
		// !

		date, err := time.Parse("2006-01-02", dateParam)
		if err != nil {
			return c.SendString("Error parsing date")
		}


		rides, err := store.GetTaxiRide(date)
		if err != nil {
			log.Fatal(err)
			return c.SendString("Error getting rides")
		}

		return c.JSON(rides)
		// return c.SendString("Hello, World!")
	})

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})
	
	app.Listen(":3000")
}