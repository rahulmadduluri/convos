package api

import (
	"log"

	"db"
	"models"
)

var dbh = db.GetHandler()

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Conversations []models.ConversationObj
	ErrorMsg      *string
}

func Search(req SearchRequest) (SearchResponse, error) {
	conversations, err := dbh.GetConversationObjs(req.SenderUUID, req.SearchText)
	if err != nil {
		log.Println("failed to get conversation for user: ", req.SenderUUID)
		log.Fatal(err)
	}
	return SearchResponse{
		Conversations: conversations,
	}, err
}
