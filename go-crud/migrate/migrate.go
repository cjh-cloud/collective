package main

import (
	"log"

	"github.com/cjh-cloud/collective/go-crud/initializers"
	"github.com/cjh-cloud/collective/go-crud/models"
	"gorm.io/gorm"
)

var DB *gorm.DB

func init() {
	// initializers.LoadEnvVariables();
	// DB := initializers.ConnectToDB();

	// if DB != nil {
	// 	log.Println("DB migrate!");
	// }

	// log.Println(DB.Migrator().CurrentDatabase());
}

func main() {
	// log.Println(initializers.DB.Migrator().CurrentDatabase());
	initializers.LoadEnvVariables();
	DB := initializers.ConnectToDB();
	if DB != nil {
		log.Println("DB main!");
	}
	log.Println(DB.Migrator().CurrentDatabase());
	DB.AutoMigrate(&models.Post{});
}