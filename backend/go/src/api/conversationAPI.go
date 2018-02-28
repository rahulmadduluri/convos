package api

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"db"

	"github.com/gorilla/mux"
)

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
