package main

import (
	"github.com/cjh-cloud/collective/go-jwt/controllers"
	"github.com/cjh-cloud/collective/go-jwt/initializers"
	"github.com/cjh-cloud/collective/go-jwt/middleware"
	"github.com/gin-gonic/gin"
)

func init() {
	initializers.LoadEnvVariables()
	// initializers.ConnectToDB()
	initializers.SyncDatabase()
}

func main() {
	// fmt.Println("Hello")
	r := gin.Default()

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)
	r.GET("/validate", middleware.RequireAuth, controllers.Validate)

	r.Run()
}
