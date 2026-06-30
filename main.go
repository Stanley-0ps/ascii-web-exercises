package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
)

const validAPIKey = "secret123"

func main() {
	// registers the handler for the /ping route
	http.HandleFunc("/ping", pingHandler)
	http.HandleFunc("/hello", helloHandler)
	http.HandleFunc("/goodbye", goodbyeHandler)
	http.HandleFunc("/count", countHandler)
	http.HandleFunc("/calculate", calculateHandler)
	http.HandleFunc("/agent", agentHandler)
	http.HandleFunc("/dashboard", dashboardHandler)
	http.HandleFunc("/legacy", legacyHandler)
	http.HandleFunc("/v2", v2Handler)
	http.HandleFunc("/method-inspector", methodInspectorHandler)
	http.HandleFunc("/echo", echoHandler)
	http.HandleFunc("/headers", headersHandler)

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

// agentHandler reads the User-Agent header and sends it back to the client
func agentHandler(w http.ResponseWriter, r *http.Request) {
	userAgent := r.Header.Get("User-Agent")
	if userAgent == "" {
		userAgent = "Unknown Device"
	}
	fmt.Fprintf(w, "You are visiting us using: %s", userAgent)
}

// dashboardHandler protects the dashboard using an API key.
func dashboardHandler(w http.ResponseWriter, r *http.Request) {
	apiKey := r.Header.Get("X-API-Key")

	if apiKey != validAPIKey {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	fmt.Fprint(w, "Welcome to the secure dashboard!")
}

// legacyHandler permanently redirects clients to the /v2 route
func legacyHandler(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, "/v2", http.StatusMovedPermanently)
}

// v2 serves as the new version of the endpoint
func v2Handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "welcome to version 2")
}

// methodInspectorHandler reports the http method used for the request
func methodInspectorHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "you made a %s request", r.Method)
}

// echoHandler reads request body and sends it back unchanged
func echoHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		return
	}
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if len(body) == 0 {
		http.Error(w, "body cannot be empty", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.Write(body)
}

func headersHandler(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("X-Custom-Token")
	contentType := r.Header.Get("content-Type")

	if token == "" {
		http.Error(w, "X-Custom-Token is missing", http.StatusBadRequest)
		return
	}

	if contentType == "" {
		contentType = "not provided"
	}

	fmt.Fprintf(w, "Token recieved: %s\nContent-Type: %s", token, contentType)
}
