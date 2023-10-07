package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	fmt.Println("Harro")

	godotenv.Load()

	portString := os.Getenv("PORT")
	if portString == "" {
		log.Fatal("Port is not found in environment")
	}

	fmt.Println("Port:", portString)
}