package api

import (
	"encoding/json"
	"net/http"
	"strconv"

	"db"

	"github.com/gorilla/mux"
)

func GetPeople(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars["uuid"]

	searchText := r.FormValue("searchtext")
	maxPeople, _ := strconv.Atoi(r.FormValue("maxpeople"))
	// If MaxPeople, isn't given, set upper bound to 100
	if maxPeople == 0 {
		maxPeople = 100 // arbitrary upper bound
	}

	people, err := db.GetHandler().GetPeople(userUUID, searchText, maxPeople)

	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "ERROR: failed to get people")
		return
	}

	respondWithJSON(w, http.StatusOK, people)
}

func UpdateUser(w http.ResponseWriter, r *http.Request) {
	// count, _ := strconv.Itoa(r.FormValue("userUUID"))
	// start, _ := strconv.Atoi(r.FormValue("searchText"))

	// objs, _ := api.GetPeople(api.SearchRequest{
	// 	SenderUUID: "uuid-1",
	// 	SearchText: "p",
	// })
	// log.Println(objs)
}

func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, _ := json.Marshal(payload)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}
