
https://www.youtube.com/watch?v=un6ZyFkqFKo

go get github.com/joho/godotenv
go get github.com/go-chi/chi 

SQLC cli
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
go install github.com/pressly/goose/v3/cmd/goose@latest

goose postgres postgres://gorss:gorss@localhost:5434/gorss up
goose postgres postgres://gorss:gorss@localhost:5434/gorss down

sqlc generate

go get github.com/lib/pq
go get github.com/google/uuid