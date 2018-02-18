package api

import (
	"net/http"
	"strconv"

	"db"

	"github.com/gorilla/mux"
)

func GetPeopleForUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxPeople, _ := strconv.Atoi(r.FormValue(_paramMaxPeople))
	// If MaxPeople, isn't given, set upper bound to 100
	if maxPeople == 0 {
		maxPeople = 100
	}

	people, err := db.GetHandler().GetPeopleForUser(userUUID, searchText, maxPeople)

	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get people")
		return
	}

	respondWithJSON(w, http.StatusOK, people)
}
