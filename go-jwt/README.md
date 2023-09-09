JWT Authentication in Go (Gin/Gorm)
https://www.youtube.com/watch?v=ma7rUS_vW9M

go mod init github.com/cjh-cloud/collective/go-jwt
go get -u gorm.io/gorm
go get -u gorm.io/driver/postgres
go get github.com/gin-gonic/gin
go get -u golang.org/x/crypto/bcrypt
go get -u github.com/golang-jwt/jwt/v4
go get github.com/joho/godotenv
go get github.com/githubnemo/CompileDaemon
<!-- go get -u golang.org/x/sys // Had to run this before install -->
export PATH=$PATH:$(go env GOPATH)/bin
