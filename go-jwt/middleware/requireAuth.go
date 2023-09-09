package middleware

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/cjh-cloud/collective/go-jwt/initializers"
	"github.com/cjh-cloud/collective/go-jwt/models"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
)

func RequireAuth(c *gin.Context) {
	fmt.Println("In middleware")

	// Get the cookie off req
	tokenString, err := c.Cookie("Authorization")

	if err != nil {
		c.AbortWithStatus(http.StatusUnauthorized)
	}

	// Decode/validate it
	// Parse
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error){
		// Don't forget to validate the alg is what you expect:
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}

		// hmacSampleSecret is a []byte container your secret, e.g.
		return []byte(os.Getenv("SECRET")), nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Check the exp
		if float64(time.Now().Unix()) > claims["exp"].(float64) {
			c.AbortWithStatus(http.StatusUnauthorized)
		}
		// Find the user with token sub
		var DB = initializers.ConnectToDB()
		var user models.User
		DB.First(&user, claims["sub"]) // get user with id matching 'sub' in JWT

		if user.ID == 0 {
			c.AbortWithStatus(http.StatusUnauthorized)
		}
		
		// Attach to req
		c.Set("user", user)
		
		// Continue
		c.Next()
		
		// fmt.Println(claims["foo"], claims["nbf"])
	} else {
		c.AbortWithStatus(http.StatusUnauthorized)
	}

	
}