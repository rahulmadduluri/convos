package api

import (
	"db"
	"log"
	"models"
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

type ConversationResponse struct {
	ConversationUUID       string
	PhotoURL               string
	UpdatedTimestampServer int
	Title                  string
	IsDefault              bool
	GroupUUID              string
	GroupPhotoURL          string
}

func Search(req SearchRequest) (SearchResponse, error) {
	// run SQL query with request to get correct response data
	log.Println(req)
	name := req.SearchText
	// dbh.GetConversationsByName(name), not yet implemented
	return SearchResponse{
		Conversations: []ConversationResponse{},
	}, nil
}
