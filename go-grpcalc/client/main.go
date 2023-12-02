package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"github.com/cjh-cloud/collective/go-grpcalc/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	// creating gRPC connection for us
	serverAddr := flag.String(
		"server", "localhost:8080",
		"The server address in the format of host:port",
	)
	flag.Parse()

	// * When using TLS
	// creds := credentials.NewTLS(&tls.Config{InsecureSkipVerify: false})

	// opts := []grpc.DialOption{
	// 	grpc.WithTransportCredentials(creds),
	// }

	// * When running locally without TLS
	opts := []grpc.DialOption{
			grpc.WithTransportCredentials(insecure.NewCredentials()),
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(ctx, *serverAddr, opts...)
	if err != nil {
		log.Fatalln("fail to dial:", err)
	}
	defer conn.Close()
	// creating gRPC connection for us

	client := pb.NewCalculatorClient(conn)

	res, err := client.Sum(ctx, &pb.NumbersRequest{
		Numbers: []int64{10, 10, 10, 10, 10},
	})
	if err != nil {
		log.Fatalln("error sending request:", err)
	}

	fmt.Println("result:", *res.Result)
}