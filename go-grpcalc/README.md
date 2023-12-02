# GRPC Caluclator 
https://www.youtube.com/watch?v=_4TPM6clQjM
https://github.com/dreamsofcode-io/grpc/tree/main

brew install grpcui

go mod init github.com/cjh-cloud/collective/go-grpcalc

brew install protobuf

go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1

protoc --proto_path=proto proto/*.proto --go_out=. --go-grpc_out=.
make generate

go get google.golang.org/grpc



go run server/main.go
grpcui --plaintext 127.0.0.1:8080

changes to calculator.proto requires `make generate`
