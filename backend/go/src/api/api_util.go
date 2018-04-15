package api

import (
	"encoding/json"
	"log"
	"net/http"
)

const (
	_paramUUID       = "uuid"
	_paramSearchText = "searchtext"
	_paramName       = "name"
	_paramHandle     = "handle"
	// User
	_paramMobileNumber = "mobilenumber"
	_paramMaxContacts  = "maxcontacts"
	_paramMaxUsers     = "maxusers"
	_paramContactUUID  = "contactuuid"
	// Group
	_paramMaxMembers  = "maxmembers"
	_paramGroupUUID   = "groupuuid"
	_paramMemberUUID  = "memberuuid"
	_paramMemberUUIDs = "memberuuids"
	// Conversation
	_paramMaxConversations = "maxconversations"
	// Tags
	_paramTopic    = "topic"
	_paramTagUUID  = "taguuid"
	_paramTagUUIDs = "taguuids"
	_paramTagNames = "tagnames"
	_paramTagName  = "tagname"
	_paramMaxTags  = "maxtags"
	// Image Size
	_24K = (1 << 10) * 24
)

func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if code >= 300 {
		w.WriteHeader(code)
	}
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Println(err)
	}
}
