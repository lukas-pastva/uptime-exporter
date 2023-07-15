package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	filePath := "/tmp/metrics.log"

	// Check if file exists
	if _, err := os.Stat(filePath); err != nil {
		if os.IsNotExist(err) {
			fmt.Println("File does not exist.")
			return
		}
	}

	// Open file
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	// Echo contents of the file
	_, err = io.Copy(os.Stdout, file)
	if err != nil {
		fmt.Println("Error reading file:", err)
	}

	//cmd, err := exec.Command("/bin/sh", "/usr/local/bin/metrics.sh").Output()
	//if err != nil {
	//	fmt.Printf("error %s", err)
	//}
	//output := string(cmd)
	//fmt.Fprintf(w, output)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":80", nil)
}
