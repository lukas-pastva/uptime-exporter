package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"sync"
	"time"
)

var (
	scriptRunning bool
	scriptMutex   sync.Mutex
)

func executeScript() {
	scriptMutex.Lock()
	defer scriptMutex.Unlock()

	if scriptRunning {
		fmt.Println("Script is already running.")
		return
	}

	scriptRunning = true
	defer func() { scriptRunning = false }()

	err := exec.Command("/bin/bash", "/usr/local/bin/metrics.sh").Run()
	if err != nil {
		fmt.Println("Error executing script:", err)
	}
}

func ensureLogFileExists() {
	filePath := "/tmp/metrics.log"
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		// File does not exist, create it
		currentTime := time.Now().Unix()
		content := fmt.Sprintf("uptime_exporter_heart_beat %d\n", currentTime)
		err := os.WriteFile(filePath, []byte(content), 0644)
		if err != nil {
			fmt.Println("Error creating file:", err)
		}
	}
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ensureLogFileExists()

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

		// Execute the bash script asynchronously, if not already running
		go executeScript()
	})

	fmt.Println("Server is listening on port 9199...")
	if err := http.ListenAndServe(":9199", nil); err != nil {
		fmt.Println("Server failed to start:", err)
	}
}
