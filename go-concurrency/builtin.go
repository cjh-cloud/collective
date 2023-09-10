package main

import (
	"fmt"
	"time"
)

// pass in done as a read only channel
func doWork(done <-chan bool) {
	// for-select pattern, need select to check for done
	for {
		select {
		case <-done:
			return
		default:
			fmt.Println("DOING WORK")
		}
	}
}

func main() {

	done := make(chan bool)

	// Infinte go routine
	// go func() {
	// 	for {
	// 		select {
	// 		default:
	// 			fmt.Println("DOING WORK")
	// 		}
	// 	}
	// }()

	go doWork(done)

	time.Sleep(time.Second * 10)
	// time.Sleep(time.Hour * 299)

	close(done)
}