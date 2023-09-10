package main

import "fmt"

func main() {
	charChannel := make(chan string, 3) // limited capacity of 3 - buffered
	chars := []string{"a", "b", "c"}

	for _, s := range chars {
		select {
		case charChannel <- s:
		}
		// could just do charChannek <- s, but we don't...
	}

	close(charChannel)

	// channel is closed but able to loop over data
	for result := range charChannel {
		fmt.Println(result)
	}
}