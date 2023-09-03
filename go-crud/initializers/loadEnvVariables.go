package initializers

import (
	"log"

	"github.com/joho/godotenv"
)

// Needs to start with capital letter to be used in other files
func LoadEnvVariables() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
}