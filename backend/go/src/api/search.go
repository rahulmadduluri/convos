package api

import (
	"log"
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
	if err != nil {
		log.Println("failed to get conversation for user: ", req.SenderUUID, ", searchText: ", req.SearchText)
		log.Println(err)
	}
	return SearchResponse{
		Groups: groups,
	}, err
}
