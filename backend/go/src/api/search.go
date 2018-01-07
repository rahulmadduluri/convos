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
	conversations, err := dbh.GetConversationObjs(req.SenderUUID, req.SearchText)
	if err != nil {
		log.Println("failed to get conversation for user: ", req.SenderUUID)
		log.Println(req.SearchText)
		log.Println(err)
	}
	return SearchResponse{
		Groups: groups,
	}, err
}
