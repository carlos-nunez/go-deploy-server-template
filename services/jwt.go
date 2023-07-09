package services

import "os"

var DEPLOY_KEY = os.Getenv("DEPLOY_KEY")

func ValidateToken(Key string) bool {
	if DEPLOY_KEY == Key {
		return true
	} else {
		return false
	}
}
