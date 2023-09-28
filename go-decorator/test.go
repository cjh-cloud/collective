// package main

// import "fmt"

// type DB interface {
// 	Store(string) error
// }



// func myExecuteFunc(s string) {
// 	// access to DB??
// 	fmt.Println("my ex func", s)
// }

// func main() {
// 	Execute(myExecuteFunc)
// }

// // This is coming from a third party lib
// type ExecuteFn func(string)

// func Execute(fn ExecuteFn) {
// 	fn("FOO BAR BAZ")
// }