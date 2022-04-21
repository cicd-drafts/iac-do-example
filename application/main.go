package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	fs := func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello janbo from @RustamGimadiev")
	}

	http.HandleFunc("/", fs)

	log.Println("Listening on :11130...")
	err := http.ListenAndServe(":11130", nil)
	if err != nil {
		log.Fatal(err)
	}
}
