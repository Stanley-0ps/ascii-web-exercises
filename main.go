package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	// registers the handler for the /ping route
	http.HandleFunc("/ping", pingHandler)
	http.HandleFunc("/hello", helloHandler)
	http.HandleFunc("/goodbye", goodbyeHandler)

	fmt.Println("Server is running on http://localhost:8080")

	// start the HTTP Server
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}

// pingHandler handles requests to the /ping route
func pingHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "pong")
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	//Allow only GET requests.
	if r.Method != http.MethodGet {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}

	// Read the "name" query parameter
	name := r.URL.Query().Get("name")
	if name == "" {
		name = "Guest"
	}

	// send the response
	fmt.Fprintf(w, "Hello, %s!", name)
}

func goodbyeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "GoodBye!")
}
