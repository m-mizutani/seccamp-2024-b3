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
	f, err := os.Open("config.json")
	if err != nil {
		panic(err)
	}

	defer f.Close()

	type Config struct {
		Members []Member `json:"members"`
	}

	var cfg Config
	err = json.NewDecoder(f).Decode(&cfg)
	if err != nil {
		panic(err)
	}

	for _, member := range cfg.Members {
		// get sha256 hash of email
		h := sha256.New()
		h.Write([]byte(member.Email))
		h.Write([]byte("seccamp2024"))

		fmt.Printf("%s,%s\n", member.ID, hex.EncodeToString(h.Sum(nil)))
	}
}
