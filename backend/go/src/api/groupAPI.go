package api

import (
	"net/http"
	"strconv"
	"time"

	"db"

	"github.com/gorilla/mux"
	"github.com/satori/go.uuid"
)

const (
	_paramMemberUUID = "memberuuid"
)

func GetPeopleForGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxPeople, _ := strconv.Atoi(r.FormValue(_paramMaxPeople))
	// If MaxPeople, isn't given, set upper bound to 100
	if maxPeople == 0 {
		maxPeople = 100
	}

	people, err := db.GetHandler().GetPeopleForGroup(groupUUID, searchText, maxPeople)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get people")
		return
	}
	respondWithJSON(w, http.StatusOK, people)
}

func UpdateGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]
	name := r.FormValue(_paramName)
	newMemberUUID := r.FormValue(_paramMemberUUID)
	timestampServer := int(time.Now().Unix())

	err := db.GetHandler().UpdateGroup(groupUUID, name, timestampServer, newMemberUUID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to update group")
	}
	respondWithJSON(w, http.StatusOK, nil)
}

func UpdateGroupPhoto(w http.ResponseWriter, r *http.Request) {
	respondWithJSON(w, http.StatusOK, nil)
}

func CreateGroup(w http.ResponseWriter, r *http.Request) {
	// read multipart form to get name, members, and image
	groupUUIDRaw, _ := uuid.NewV4()
	groupUUID := groupUUIDRaw.String()
	name := "TEST NAME"
	createdTimestampServer := int(time.Now().Unix())
	photoURI := name + ".png"
	newMemberUUIDs := []string{}

	err := db.GetHandler().CreateGroup(groupUUID, name, createdTimestampServer, photoURI, newMemberUUIDs)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to create group")
	}
	respondWithJSON(w, http.StatusOK, nil)
}
