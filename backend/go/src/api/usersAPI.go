package api

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"db"
	"middleware"

	"github.com/gorilla/mux"
)

func UpdateUser(w http.ResponseWriter, r *http.Request) {
	if middleware.HasUUID(r.Header) && middleware.CheckUUIDParam(r) {
		vars := mux.Vars(r)
		userUUID, _ := vars[_paramUUID]
		name := r.FormValue(_paramName)
		handle := r.FormValue(_paramHandle)

		err := db.GetHandler().UpdateUser(userUUID, name, handle)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "failed to update user")
		}
		respondWithJSON(w, http.StatusOK, nil)
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to update user")
	}
}

func GetUser(w http.ResponseWriter, r *http.Request) {
	if middleware.HasUUID(r.Header) && middleware.CheckUUIDParam(r) {
		user, err := db.GetHandler().GetUser(uuid)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "failed to get user")
			return
		}
		respondWithJSON(w, http.StatusOK, user)
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to get user")
	}
}

func GetContactsForUser(w http.ResponseWriter, r *http.Request) {
	if middleware.HasUUID(r.Header) && middleware.CheckUUIDParam(r) {
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
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to get contacts")
	}
}

func CreateContact(w http.ResponseWriter, r *http.Request) {
	if middleware.HasUUID(r.Header) && middleware.CheckUUIDParam(r) {
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
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to create contact")
	}
}
