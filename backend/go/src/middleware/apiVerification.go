package middleware

import (
	"net/http"

	"github.com/gorilla/mux"
)

// Gets UUID from header so that API can check that authorization is permitted
func GetUUIDFromHeader(header http.Header) string {
	return header.Get("x-uuid")
}

// Checks user UUID in parameters to make sure it's the same as the Header's UUID
func CheckUUIDParamMatchesHeader(r *http.Request) bool {
	vars := mux.Vars(r)
	if userUUID, ok := vars["uuid"]; ok && userUUID != "" {
		return r.Header.Get("x-uuid") == userUUID
	} else {
		return false
	}
}
