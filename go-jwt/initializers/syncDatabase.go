package initializers

import (
	"log"

	"github.com/cjh-cloud/collective/go-jwt/models"
)

func SyncDatabase() {
	var DB = ConnectToDB() // TODO : pass in DB object to this func
	DB.AutoMigrate(&models.User{})
	log.Println("Migrated?")
}