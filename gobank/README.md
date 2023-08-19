How To Build A Complete JSON API In Goland (JWT, Postgres, and Docker Part 1)
https://www.youtube.com/watch?v=pwZuNmAzaH8&list=PL0xRBLFXXsP6nudFDqMXzrvQCZrxSOm-2&index=1

go mod init github.com/cjh-cloud/collective
go get github.com/gorilla/mux

docker run --name some-postgres -e POSTGRES_PASSWORD=gobank -p 5432:5432 -d postgres
go get github.com/lib/pq

go get -u github.com/golang-jwt/jwt/v4
export JWT_SECRET=something_secure

go get golang.org/x/crypto/bcrypt
go get github.com/stretchr/testify/assert
go test ./... -v
./bin/gobank --seed // seeds the db by setting seed flag to true