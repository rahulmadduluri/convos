package api

import (
	"models"
)

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Conversations []models.Conversation
}

func RecvSearchRequest(req SearchRequest) {
	// run SQL query with request to get correct response data

}

func RecvSearchResponse(res SearchResponse) {
	// run SQL query with request to get correct response data

}
