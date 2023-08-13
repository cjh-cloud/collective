Go API Tutorial - Make an API with Go
https://www.youtube.com/watch?v=bj77B59nkTQ

go mod init example/Go-Api-Tutorial
go get github.com/gin-gonic/gin

go run main.go

curl localhost:8080/books --include --header "Content-Type: application/json" -d @body.json --request "POST"

curl "localhost:8080/checkout?id=2" --request "PATCH"
curl "localhost:8080/checkout?id=4" --request "PATCH"
curl "localhost:8080/checkout" --request "PATCH"

curl "localhost:8080/return?id=2" --request "PATCH"
curl "localhost:8080/return?id=5" --request "PATCH"
curl "localhost:8080/return" --request "PATCH"
