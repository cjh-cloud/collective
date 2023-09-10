package main

import "fmt"

// channels is a primitive
// channels implements fork join model
func main() {
	myChannel := make(chan string) // unbuffered channel - comms between goroutines is instant
	anotherChannel := make(chan string)

	// fork
	// anon func go routine
	go func () {
		myChannel <- "data" // send data to the channel
	}() // () invokes it

	go func () {
		anotherChannel <- "cow"
	}()

	// join
	// blocking - wait till message received, or channel closed
	// msg :=  <-myChannel // main() is reading from channel
	// fmt.Println(msg)

	// select is another primitive
	select {
	case msgFromMyChannel := <- myChannel:
		fmt.Println(msgFromMyChannel)
	case msgFromAnotherChannel := <- anotherChannel:
		fmt.Println(msgFromAnotherChannel)
	}
}
