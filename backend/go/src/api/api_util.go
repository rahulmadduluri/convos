package api

import (
	"encoding/json"
	"log"
	"net/http"
)

const (
	_paramUUID       = "uuid"
	_paramSearchText = "searchtext"
	_paramMaxPeople  = "maxpeople"
	_paramName       = "name"
	// Group
	_paramGroupUUID = "groupuuid"
	// Members
	_paramMemberUUID  = "memberuuid"
	_paramMemberUUIDs = "memberuuids"
	// Tags
	_paramTopic    = "topic"
	_paramTagUUID  = "taguuid"
	_paramTagUUIDs = "taguuids"
	_paramTagNames = "tagnames"
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
