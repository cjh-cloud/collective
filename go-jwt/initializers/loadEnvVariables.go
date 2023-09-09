package initializers

import (
	"log"

	"github.com/joho/godotenv"
)

// Starting with capital letters lets you use the func in other packages
func LoadEnvVariables() {
	err := godotenv.Load()

	if err != nil {
		log.Fatal("Error loading .env file")
	}
}