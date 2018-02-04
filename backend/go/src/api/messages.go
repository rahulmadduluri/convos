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
	LatestTimestampServer *int
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

func PullMessages(req PullMessagesRequest) (*PullMessagesResponse, error) {
	// get last X messages before latestTimestampServer. Returned in reverse chronological order
	log.Println(req)
	latestTimestampServer := int(time.Now().Unix())
	if req.LatestTimestampServer != nil {
		latestTimestampServer = *req.LatestTimestampServer
	}
	log.Println(req.ConversationUUID, req.LastXMessages, latestTimestampServer)
	messages, err := dbh.GetLastXMessages(req.ConversationUUID, req.LastXMessages, latestTimestampServer)
	if err != nil {
		log.Println("failed to get messages for req", req)
		log.Println(err)
	}
	return &PullMessagesResponse{
		Messages: messages,
	}, err
}

func PushMessage(req PushMessageRequest) (*PushMessageResponse, []string, error) {
	// first add message to messages table, then add the conversation_messages relationship. DOne in single query
	log.Println(req)
	originalMessageUUID, _ := uuid.NewV4()
	messageUUID := originalMessageUUID.String()

	timestampServer := int(time.Now().Unix())
	users, err := dbh.InsertMessage(messageUUID, req.AllText, timestampServer, req.SenderUUID, req.ParentUUID, req.ConversationUUID)
	if err != nil {
		log.Println("failed to add message to tables. Insert failed", req)
		fmt.Println(err)
		return nil, nil, err
	}

	var receiveruuids []string
	for _, user := range users {
		receiveruuids = append(receiveruuids, user.UUID)
	}

	return &PushMessageResponse{
		Message: models.MessageObj{
			UUID:                   messageUUID,
			AllText:                req.AllText,
			CreatedTimestampServer: timestampServer,
			SenderUUID:             req.SenderUUID,
			ParentUUID:             req.ParentUUID,
			SenderPhotoURI:         "", // TODO: Fix this
		},
	}, receiveruuids, err
}
