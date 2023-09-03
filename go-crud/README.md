Creating a JSON CRUD API in Go (Gin/GORM)
https://www.youtube.com/watch?v=lf_kiH_NPvM

go mod init github.com/cjh-cloud/collective/go-crud
go get github.com/githubnemo/CompileDaemon
go get -u golang.org/x/sys // Had to run this before install
go install github.com/githubnemo/CompileDaemon
go get github.com/joho/godotenv
go get github.com/gin-gonic/gin
go get -u gorm.io/gorm
go get -u gorm.io/driver/sqlite

export PATH=$PATH:$(go env GOPATH)/bin
CompileDaemon -command="./go-crud"

go get github.com/jinzhu/gorm/dialects/postgres // This was wrong
go get gorm.io/driver/postgres