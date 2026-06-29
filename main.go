package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
)

func main() {
	// registers the handler for the /ping route
	http.HandleFunc("/ping", pingHandler)
	http.HandleFunc("/hello", helloHandler)
	http.HandleFunc("/goodbye", goodbyeHandler)
	http.HandleFunc("/count", countHandler)
	http.HandleFunc("/calculate", calculateHandler)

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

func countHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		fmt.Fprint(w, "Send a POST request with text to count words")

	case http.MethodPost:
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Unable to read request body", http.StatusInternalServerError)
			return
		}
		length := len(body)
		fmt.Fprintf(w, "%d", length)

	default:
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
	}
}

// calculateHandler performs basic arithmethic using query parameters
func calculateHandler(w http.ResponseWriter, r *http.Request) {
	// read the query parameter
	operations := r.URL.Query().Get("op")
	aString := r.URL.Query().Get("a")
	bString := r.URL.Query().Get("b")

	a, err := strconv.Atoi(aString)
	if err != nil {
		http.Error(w, "Invalid value for 'a'", http.StatusBadRequest)
		return
	}

	b, err := strconv.Atoi(bString)
	if err != nil {
		http.Error(w, "Invalid value for 'b'", http.StatusBadRequest)
		return
	}

	var result int

	switch operations {
	case "add":
		result = a + b
	case "subtract":
		result = a - b
	case "multiply":
		result = a * b

	default:
		http.Error(w, "Unknown operation", http.StatusBadRequest)
		return
	}

	fmt.Fprintf(w, "Result: %d", result)
}
