package main

import (
	"fmt"
	"time"
)

func someFunc(num string) {
	fmt.Println(num)
}

func main() {
	// fork
	go someFunc("1") // go routine
	go someFunc("2")
	go someFunc("3")

	time.Sleep(time.Second * 2)

	fmt.Println("hi")
}