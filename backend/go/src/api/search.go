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
	conversationUUID         string
	photo_url                string
	created_timestamp_server int
	title                    string
	groupUUID                string
	isDefault                bool
}

type Conversation struct {
	ID                       int
	UUID                     string
	Photo_url                *string
	Created_timestamp_server int
	Topic_tag_uuid           int
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
