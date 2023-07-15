package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Read the contents of the file
		contents, err := ioutil.ReadFile("/tmp/metrics.log")
		if err != nil {
			// If there is an error reading the file, write an error message and return
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprint(w, "Error reading file: ", err)
			return
		}

		// Write the contents of the file to the response
		fmt.Fprint(w, string(contents))
	})

	fmt.Println("Server is listening on port 80...")
	if err := http.ListenAndServe(":80", nil); err != nil {
		fmt.Println("Server failed to start:", err)
	}
}
