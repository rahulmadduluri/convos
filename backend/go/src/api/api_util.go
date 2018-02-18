package api

import (
	"encoding/json"
	"log"
	"net/http"
)

const (
	_paramUUID       = "uuid"
	_paramSearchText = "searchtext"
	_paramMaxPeople  = "maxpeople"
	_paramName       = "name"
)

func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Println(err)
	}
}
