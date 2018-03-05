package api

import (
	"net/http"
	"strconv"

	"db"

	"github.com/gorilla/mux"
)

func GetContactsForUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxContacts, _ := strconv.Atoi(r.FormValue(_paramMaxContacts))
	// If maxContacts, isn't given, set upper bound to 100
	if maxContacts == 0 {
		maxContacts = 100
	}

	contacts, err := db.GetHandler().GetContactsForUser(userUUID, searchText, maxContacts)

	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get contacts")
		return
	}

	respondWithJSON(w, http.StatusOK, contacts)
}
