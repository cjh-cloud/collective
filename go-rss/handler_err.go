package main

import "net/http"

func handlerErr(w http.ResponseWriter, r *http.Request) {
	// Empty struct, marshal to payload object
	respondWithJSON(w, 400, "Something went wrong")
}