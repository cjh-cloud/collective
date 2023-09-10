package main

import "fmt"

// func won't wait for the go routine, will just return channel
func sliceToChannel(nums []int) <-chan int {
	out := make(chan int) // unbuffered, synchronous
	go func() { // go routine
		for _, n :=  range nums { // what is _? try logging
			out <- n
		}
		close(out)
	}()
	return out
}

func sq(in <-chan int)  <-chan int {
	out := make(chan int) // unbuffered
	go func() {
		for n := range in { // will keep ranging to 'in' is closed
			out <- n * n
		}
		close(out)
	}()
	return out
}

func main() {
	// input
	nums := []int{2, 3, 4, 7, 1}
	// stage 1
	dataChannel := sliceToChannel(nums)
	// stage 2 - pass output from stage 1 into another stage
	finalChannel := sq(dataChannel)
	// stage 3 - output results of the pipeline
	for n := range finalChannel {
		fmt.Println(n)
	}
}