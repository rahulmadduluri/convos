package api

import (
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

func Search(req SearchRequest) (SearchResponse, error) {
	groups, err := dbh.GetGroupObjs(req.SenderUUID, req.SearchText)
	return SearchResponse{
		Groups: groups,
	}, err
}
