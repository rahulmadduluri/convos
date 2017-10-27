package api

import (
	"fmt"

	"models"
)

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Conversations []models.Conversation
	ErrorMsg      *string
}

func Search(req SearchRequest) (SearchResponse, error) {
	// run SQL query with request to get correct response data
	fmt.Println(req)
	return SearchResponse{
		Conversations: []models.Conversation{},
	}, nil
}
