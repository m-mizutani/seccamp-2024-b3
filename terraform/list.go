package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
)

type Member struct {
	Email string `json:"email"`
	ID    string `json:"id"`
}

func main() {
	f, err := os.Open("members.json")
	if err != nil {
		panic(err)
	}

	defer f.Close()

	type JsonData struct {
		Members []Member `json:"members"`
	}

	var data JsonData
	err = json.NewDecoder(f).Decode(&data)
	if err != nil {
		panic(err)
	}

	for _, member := range data.Members {
		// get sha256 hash of email
		h := sha256.New()
		h.Write([]byte(member.Email))
		h.Write([]byte("seccamp2024"))

		fmt.Printf("%s,%s\n", member.ID, hex.EncodeToString(h.Sum(nil)))
	}
}
