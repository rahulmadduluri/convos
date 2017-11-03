package api

import (
	"db"
	"log"
)

var dbh = db.GetDbHandler()

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Conversations []ConversationResponse
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
	// run SQL query with request to get correct response data
	log.Println(req)
	name := req.SearchText
	// dbh.GetConversationsByName(name), not yet implemented
	return SearchResponse{
		Conversations: []ConversationObj{},
	}, nil
}
