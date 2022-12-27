go mod init github.com/cjh-cloud/collective
go get "github.com/jinzhu/gorm"
go get "github.com/jinzhu/gorm/dialects/mysql"
go get "github.com/gorilla/mux"

cd cmd/main
go build # Will create a lot of errors

go run main.go # within cmd/main
curl localhost:9010/book/
curl localhost:9010/book/ -X POST --data "{\"Name\":\"Zero to One\", \"Author\":\"Peter Thiel\", \"Publication\":\"Penguin\"}"
curl localhost:9010/book/ -X POST --data "{\"Name\":\"The startup way\", \"Author\":\"Eric Ries\", \"Publication\":\"Penguin\"}"
curl localhost:9010/book/2 -X PUT --data "{\"Name\":\"The startup way\", \"Author\":\"Eric Ries\", \"Publication\":\"Orion\"}"
curl localhost:9010/book/2 -X DELETE
