package api

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"db"

	"github.com/gorilla/mux"
)

func UpdateUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars[_paramUUID]
	name := r.FormValue(_paramName)

	err := db.GetHandler().UpdateUser(userUUID, name)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to update user")
	}
	respondWithJSON(w, http.StatusOK, nil)
}

func GetUsers(w http.ResponseWriter, r *http.Request) {
	searchText := r.FormValue(_paramSearchText)
	maxUsers, _ := strconv.Atoi(r.FormValue(_paramMaxUsers))
	// If maxUsers, isn't given, set upper bound to 100
	if maxUsers == 0 {
		maxUsers = 30
	}

	users, err := db.GetHandler().GetUsers(searchText, maxUsers)

	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get users")
		return
	}

	respondWithJSON(w, http.StatusOK, users)
}

func GetContactsForUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxContacts, _ := strconv.Atoi(r.FormValue(_paramMaxContacts))
	// If maxContacts, isn't given, set upper bound to 100
	if maxContacts == 0 {
		maxContacts = 30
	}

	contacts, err := db.GetHandler().GetContactsForUser(userUUID, searchText, maxContacts)

	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get contacts")
		return
	}

	respondWithJSON(w, http.StatusOK, contacts)
}

func CreateContact(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID, _ := vars[_paramUUID]

	contactUUID := r.PostFormValue(_paramContactUUID)
	createdTimestampServer := int(time.Now().Unix())

	err := db.GetHandler().CreateContact(userUUID, contactUUID, createdTimestampServer)
	if err != nil {
		log.Println(err)
		respondWithError(w, http.StatusInternalServerError, "failed to create contact")
	}
	respondWithJSON(w, http.StatusOK, nil)
}
