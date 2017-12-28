package api

import (
	"db"
	"fmt"
	"github.com/guregu/null"
	"github.com/satori/go.uuid"
	"log"
	"models"
	"time"
)

var dbh = db.GetHandler()

type PullMessagesRequest struct {
	ConversationUUID      string
	LastXMessages         int
	LatestServerTimestamp *int
}

type PullMessagesResponse struct {
	Messages []models.MessageObj
	ErrorMsg *string
}

type PushMessageRequest struct {
	ConversationUUID string
	AllText          string
	SenderUUID       string
	ParentUUID       null.String // TODO: Handle case of this being null in the insert
}

type PushMessageResponse struct {
	Message  models.MessageObj
	ErrorMsg *string
}

func PullMessages(req PullMessagesRequest) (PullMessagesResponse, error) {
	// get last X messages before latestServerTimestamp. Returned in reverse chronological order
	log.Println(req)
	latestServerTimestamp := int(time.Now().Unix())
	if req.LatestServerTimestamp != nil {
		latestServerTimestamp = *req.LatestServerTimestamp
	}
	log.Println(req.ConversationUUID, req.LastXMessages, latestServerTimestamp)
	messages, err := dbh.GetLastXMessages(req.ConversationUUID, req.LastXMessages, latestServerTimestamp)
	if err != nil {
		log.Println("failed to get messages for req", req)
		log.Println(err)
	}
	return PullMessagesResponse{
		Messages: messages,
	}, err
}

func PushMessage(req PushMessageRequest) (PushMessageResponse, []string, error) {
	// first add message to messages table, then add the conversation_messages relationship. DOne in single query
	log.Println(req)
	messageUUID := uuid.NewV4().String()
	serverTimestamp := int(time.Now().Unix())
	users, err := dbh.InsertMessage(messageUUID, req.AllText, serverTimestamp, req.SenderUUID, req.ParentUUID, req.ConversationUUID)
	if err != nil {
		log.Println("failed to add message to tables", req)
		fmt.Println(err)
	}

	var receiveruuids []string
	for _, user := range users {
		receiveruuids = append(receiveruuids, user.UUID)
	}
	log.Println(receiveruuids)
	return PushMessageResponse{
		Message: models.MessageObj{
			UUID:                   messageUUID,
			AllText:                req.AllText,
			CreatedTimestampServer: serverTimestamp,
			SenderUUID:             req.SenderUUID,
			ParentUUID:             req.ParentUUID,
			SenderPhotoURL:         "", // TODO: Fix this
		},
	}, receiveruuids, err
}
