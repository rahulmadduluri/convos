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

func GetTagsForConversation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	conversationUUID, _ := vars[_paramUUID]

	searchText := r.FormValue(_paramSearchText)
	maxTags, _ := strconv.Atoi(r.FormValue(_paramMaxTags))
	// If MaxTags, isn't given, set upper bound to 20
	if maxTags == 0 {
		maxTags = 20
	}

	tags, err := db.GetHandler().GetTagsForConversation(conversationUUID, searchText, maxTags)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to get tags")
		return
	}
	respondWithJSON(w, http.StatusOK, tags)
}

func UpdateConversation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	conversationUUID, _ := vars[_paramUUID]
	topic := r.FormValue(_paramTopic)
	newTagUUID := r.FormValue(_paramTagUUID)
	timestampServer := int(time.Now().Unix())

	err := db.GetHandler().UpdateConversation(conversationUUID, topic, timestampServer, newTagUUID)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to update conversation")
	}
	respondWithJSON(w, http.StatusOK, nil)
}

func UpdateConversationPhoto(w http.ResponseWriter, r *http.Request) {
	respondWithJSON(w, http.StatusOK, nil)
}

func CreateConversation(w http.ResponseWriter, r *http.Request) {
	groupUUID := r.PostFormValue(_paramGroupUUID)
	topic := r.PostFormValue(_paramTopic)
	createdTimestampServer := int(time.Now().Unix())
	photoURI := "conversation." + topic + ".png"

	var tagNames []string
	json.Unmarshal([]byte(r.PostFormValue(_paramTagNames)), &tagNames)

	err := db.GetHandler().CreateConversation(groupUUID, topic, tagNames, createdTimestampServer, photoURI)
	if err != nil {
		log.Println(err)
		respondWithError(w, http.StatusInternalServerError, "failed to create group")
	}
	respondWithJSON(w, http.StatusOK, nil)
}
