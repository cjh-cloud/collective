package main

import "net/http"

func handlerReadiness(w http.ResponseWriter, r *http.Request) {
	// Empty struct, marshal to payload object
	respondWithJSON(w, 200, struct{}{})
}