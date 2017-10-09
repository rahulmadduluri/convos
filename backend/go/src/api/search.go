package api

import "models"

type SearchRequest struct {
	SenderUuid string
	SearchText string
}

type SearchResponse struct {
	Conversations []models.Conversations
}
