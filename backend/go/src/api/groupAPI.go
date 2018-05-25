package api

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"db"
	"middleware"

	"github.com/gorilla/mux"
)

func GetGroups(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID := middleware.GetUUIDFromHeader(r.Header)
	searchText, _ := vars[_paramSearchText]

	groups, err := db.GetHandler().GetGroups(userUUID, searchText)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "search: failed to get groups")
	} else {
		respondWithJSON(w, http.StatusOK, groups)
	}
}

func GetConversationsForGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	// make sure authorized userUUID from header is actually in the group
	if IsMemberOfGroup(middleware.GetUUIDFromHeader(r.Header), groupUUID) {
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
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to get conversation")
	}
}

func GetMembersForGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	// make sure authorized userUUID from header is actually in the group
	if IsMemberOfGroup(middleware.GetUUIDFromHeader(r.Header), groupUUID) {
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
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to get conversation")
	}
}

func UpdateGroup(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	// make sure authorized userUUID from header is actually in the group
	if IsMemberOfGroup(middleware.GetUUIDFromHeader(r.Header), groupUUID) {
		name := r.FormValue(_paramName)
		newMemberUUID := r.FormValue(_paramMemberUUID)
		timestampServer := int(time.Now().Unix())

		err := db.GetHandler().UpdateGroup(groupUUID, name, timestampServer, newMemberUUID)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "failed to update group")
			return
		}
		respondWithJSON(w, http.StatusOK, nil)
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to update group")
	}
}

func UpdateGroupPhoto(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID, _ := vars[_paramUUID]

	// make sure authorized userUUID from header is actually in the group
	if IsMemberOfGroup(middleware.GetUUIDFromHeader(r.Header), groupUUID) {
		respondWithJSON(w, http.StatusOK, nil)
	} else {
		respondWithError(w, http.StatusUnauthorized, "failed to update group")
	}
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
		return
	}
	respondWithJSON(w, http.StatusOK, nil)
}
