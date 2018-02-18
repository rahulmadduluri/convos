package api

import (
	"time"

	"db"
	"models"

	"github.com/guregu/null"
	"github.com/satori/go.uuid"
)

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
	Message       models.MessageObj
	ReceiverUUIDs []string
	ErrorMsg      *string
}

// PullMessages is function called by Websocket Router's performAPI
func PullMessages(req PullMessagesRequest) (*PullMessagesResponse, error) {
	// get last X messages before latestTimestampServer. Returned in reverse chronological order
	latestTimestampServer := int(time.Now().Unix())
	if req.LatestTimestampServer != nil {
		latestTimestampServer = *req.LatestTimestampServer
	}
	messages, err := db.GetHandler().GetLastXMessages(req.ConversationUUID, req.LastXMessages, latestTimestampServer)
	if err != nil {
		return nil, err
	}
	return &PullMessagesResponse{
		Messages: messages,
	}, err
}

// PushMessage is function called by Websocket Router's performAPI
func PushMessage(req PushMessageRequest) (*PushMessageResponse, error) {
	originalMessageUUID, _ := uuid.NewV4()
	messageUUID := originalMessageUUID.String()

	timestampServer := int(time.Now().Unix())
	users, err := db.GetHandler().InsertMessage(messageUUID, req.AllText, timestampServer, req.SenderUUID, req.ParentUUID, req.ConversationUUID)

	if err != nil {
		return nil, err
	}

	var receiveruuids []string
	var senderPhotoURI string
	for _, user := range users {
		if user.UUID == req.SenderUUID {
			senderPhotoURI = user.PhotoURI.ValueOrZero()
		}
		receiveruuids = append(receiveruuids, user.UUID)
	}

	return &PushMessageResponse{
		Message: models.MessageObj{
			UUID:                   messageUUID,
			AllText:                req.AllText,
			CreatedTimestampServer: timestampServer,
			SenderUUID:             req.SenderUUID,
			ParentUUID:             req.ParentUUID,
			SenderPhotoURI:         senderPhotoURI,
		},
		ReceiverUUIDs: receiveruuids,
	}, err
}
