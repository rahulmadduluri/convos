package api

import (
	"encoding/json"
	"log"
	"net/http"

	"db"
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
	_paramMaxConversations      = "maxconversations"
	_paramAllText               = "alltext"
	_paramParentUUID            = "parentuuid"
	_paramConversationUUID      = "conversationuuid"
	_paramLastXMessages         = "lastxmessages"
	_paramLatestTimestampServer = "latesttimestampserver"
	_paramSenderPhotoURI        = "senderphotouri"
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

func IsMemberOfGroup(userUUID string, groupUUID string) bool {
	isMember, err := db.GetHandler().IsMemberOfGroup(userUUID, groupUUID)
	if err != nil {
		return false
	}
	return isMember
}
