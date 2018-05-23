package api

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"db"
	"middleware"
	"networking"

	"github.com/gorilla/mux"
	"github.com/guregu/null"
	"github.com/satori/go.uuid"
)

func UpdateConversation(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	conversationUUID, _ := vars[_paramUUID]
	topic := r.FormValue(_paramTopic)
	tagName := r.FormValue(_paramTagName)
	timestampServer := int(time.Now().Unix())

	err := db.GetHandler().UpdateConversation(conversationUUID, topic, timestampServer, tagName)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "failed to update conversation")
		return
	}
	respondWithJSON(w, http.StatusOK, nil)
}

func UpdateConversationPhoto(w http.ResponseWriter, r *http.Request) {
	respondWithJSON(w, http.StatusOK, nil)
}

func CreateConversation(w http.ResponseWriter, r *http.Request) {
	conversationUUIDRaw, _ := uuid.NewV4()
	conversationUUID := conversationUUIDRaw.String()

	groupUUID := r.PostFormValue(_paramGroupUUID)
	topic := r.PostFormValue(_paramTopic)
	createdTimestampServer := int(time.Now().Unix())
	photoURI := "conversation." + topic + ".png"

	var tagNames []string
	json.Unmarshal([]byte(r.PostFormValue(_paramTagNames)), &tagNames)

	err := db.GetHandler().CreateConversation(conversationUUID, groupUUID, topic, tagNames, createdTimestampServer, photoURI)
	if err != nil {
		log.Println(err)
		respondWithError(w, http.StatusInternalServerError, "failed to create group")
		return
	}

	respondWithJSON(w, http.StatusOK, nil)
}

type Message struct {
	ID                     int
	UUID                   string
	AllText                null.String
	CreatedTimestampServer int
	SenderID               int
	ParentID               int
}

func CreateMessage(w http.ResponseWriter, r *http.Request) {
	groupUUID := r.PostFormValue(_paramGroupUUID)
	userUUID := middleware.GetUUIDFromHeader(r.Header)

	if IsMemberOfGroup(userUUID, groupUUID) {
		originalMessageUUID, _ := uuid.NewV4()
		messageUUID := originalMessageUUID.String()
		timestampServer := int(time.Now().Unix())
		allText := r.PostFormValue(_paramAllText)
		parentUUID := r.PostFormValue(_paramParentUUID)
		conversationUUID := r.PostFormValue(_paramConversationUUID)

		// TODO: in background thread insert message? maybe in primary thread
		message, err := db.GetHandler().InsertMessage(messageUUID, allText, timestampServer, userUUID, parentUUID, conversationUUID)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "error: could not insert message")
		}

		topicName := groupUUID + "/" + conversationUUID
		messagePayload, err := json.Marshal(message)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "error: could not insert message")
		}
		networking.GetMQTTHandler().PublishToTopic(topicName, messagePayload)

		respondWithJSON(w, http.StatusOK, nil)
	} else {
		respondWithError(w, http.StatusUnauthorized, "unauthorized: user not in group")
	}
}
