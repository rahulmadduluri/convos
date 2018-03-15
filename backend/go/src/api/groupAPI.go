package api

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"db"

	"github.com/gorilla/mux"
)

func GetConversationsForGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	maxConversations, _ := strconv.Atoi(r.FormValue(_paramMaxConversations))
	// If maxConversations, isn't given, set upper bound to 10
	if maxConversations == 0 {
		maxConversations = 10
	}

	conversations, err := db.GetHandler().GetConversationsForGroup(groupUUID, maxConversations)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get conversations")
		return
	}
	respondWithJSON(w, http.StatusOK, conversations)
}

func GetMembersForGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxMembers, _ := strconv.Atoi(r.FormValue(_paramMaxMembers))
	// If maxMembers, isn't given, set upper bound to 30
	if maxMembers == 0 {
		maxMembers = 30
	}

	members, err := db.GetHandler().GetMembersForGroup(groupUUID, searchText, maxMembers)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get members")
		return
	}
	respondWithJSON(w, http.StatusOK, members)
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
	name := r.PostFormValue(_paramName)
	handle := r.PostFormValue(_paramHandle)
	createdTimestampServer := int(time.Now().Unix())
	photoURI := "group." + name + ".png"

	var newMemberUUIDs []string
	json.Unmarshal([]byte(r.PostFormValue(_paramMemberUUIDs)), &newMemberUUIDs)

	err := db.GetHandler().CreateGroup(name, handle, createdTimestampServer, photoURI, newMemberUUIDs)
	if err != nil {
		log.Println(err)
		respondWithError(w, http.StatusInternalServerError, "failed to create group")
	}
	respondWithJSON(w, http.StatusOK, nil)
}
