package main

import (
	"fmt"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	password := []byte("password")
	hash, err := bcrypt.GenerateFromPassword(password, 10)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(hash))
}

