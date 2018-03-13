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
	_paramMaxContacts = "maxcontacts"
	_paramMaxUsers    = "maxusers"
	_paramContactUUID = "contactuuid"
	// Group
	_paramMaxMembers = "maxmembers"
	_paramGroupUUID  = "groupuuid"
	// Members
	_paramMemberUUID  = "memberuuid"
	_paramMemberUUIDs = "memberuuids"
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
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Println(err)
	}
}
