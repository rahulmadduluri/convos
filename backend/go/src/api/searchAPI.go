package api

import (
	"db"
	"models"
)

type SearchRequest struct {
	SenderUUID string
	SearchText string
}

type SearchResponse struct {
	Groups   []models.GroupObj
	ErrorMsg *string
}

// Search is function called by Websocket Router's performAPI
func Search(req SearchRequest) (SearchResponse, error) {
	groups, err := db.GetHandler().GetGroups(req.SenderUUID, req.SearchText)
	return SearchResponse{
		Groups: groups,
	}, err
}
