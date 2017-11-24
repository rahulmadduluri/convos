package api

import (
	"log"

	"db"
)

var dbh = db.GetHandler()

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Conversations []ConversationObj
	ErrorMsg      *string
}

type ConversationObj struct {
	UUID                   string
	PhotoURL               string
	UpdatedTimestampServer int
	Title                  string
	IsDefault              bool
	GroupUUID              string
	GroupPhotoURL          string
	TopicTagUUID           string
}

func Search(req SearchRequest) (SearchResponse, error) {
	// TODO: user conversations query
	conversations := dbh.GetUsers(req.SearchText)[0]
	log.Println(conversations)
	return SearchResponse{
		Conversations: []ConversationObj{},
	}, nil
}
