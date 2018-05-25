package api

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"db"
	"middleware"
	"models"
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

func CreateMessage(w http.ResponseWriter, r *http.Request) {
	groupUUID := r.PostFormValue(_paramGroupUUID)
	userUUID := middleware.GetUUIDFromHeader(r.Header)

	if IsMemberOfGroup(userUUID, groupUUID) {
		// new message UUID + server timestamp
		originalMessageUUID, _ := uuid.NewV4()
		messageUUID := originalMessageUUID.String()
		timestampServer := int(time.Now().Unix())

		// params from POST form
		allText := r.PostFormValue(_paramAllText)
		parentUUID := r.PostFormValue(_paramParentUUID)
		conversationUUID := r.PostFormValue(_paramConversationUUID)
		senderPhotoURI := r.PostFormValue(_paramSenderPhotoURI)

		mObj := models.MessageObj{
			UUID:                   messageUUID,
			AllText:                allText,
			CreatedTimestampServer: timestampServer,
			SenderUUID:             userUUID,
			ParentUUID:             null.String{sql.NullString{}},
			SenderPhotoURI:         senderPhotoURI,
		}
		if parentUUID != "" {
			mObj.ParentUUID = null.NewString(parentUUID, true)
		}

		topicName := groupUUID + "/" + conversationUUID
		messagePayload, err := json.Marshal(mObj)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "error: could not marshall message")
		}
		networking.GetMQTTHandler().PublishToTopic(topicName, messagePayload)

		// perform sql insert async?
		err = db.GetHandler().InsertMessage(messageUUID, allText, timestampServer, userUUID, parentUUID, conversationUUID)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "error: could not insert message")
		} else {
			respondWithJSON(w, http.StatusOK, mObj)
		}
	} else {
		respondWithError(w, http.StatusUnauthorized, "unauthorized: user not in group")
	}
}

func GetMessages(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	groupUUID := vars[_paramGroupUUID]
	userUUID := middleware.GetUUIDFromHeader(r.Header)

	if IsMemberOfGroup(userUUID, groupUUID) {
		conversationUUID := vars[_paramConversationUUID]
		lastXMessages, _ := strconv.Atoi(vars[_paramLastXMessages])
		timestampServer, _ := strconv.Atoi(vars[_paramLatestTimestampServer])

		messages, err := db.GetHandler().GetLastXMessages(conversationUUID, lastXMessages, timestampServer)
		if err != nil {
			respondWithError(w, http.StatusInternalServerError, "error: failed to get messages")
			return
		}
		respondWithJSON(w, http.StatusOK, messages)
	} else {
		respondWithError(w, http.StatusUnauthorized, "unauthorized: user not in group")
	}
}
