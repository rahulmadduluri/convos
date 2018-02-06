package networking

import (
	"log"
	"time"

	"api"
	"models"

	"encoding/json"
)

type APIType string

const (
	_searchRequest        APIType = "SearchRequest"
	_searchResponse       APIType = "SearchResponse"
	_pullMessagesRequest  APIType = "PullMessagesRequest"
	_pullMessagesResponse APIType = "PullMessagesResponse"
	_pushMessageRequest   APIType = "PushMessageRequest"
	_pushMessageResponse  APIType = "PushMessageResponse"
)

func routeAPI(data json.RawMessage, apiType APIType) (*Packet, error) {
	var err error
	var resType APIType

	// handle request
	var genericResponse models.Model
	switch apiType {
	case _searchRequest:
		var searchRequest api.SearchRequest
		err = json.Unmarshal(data, &searchRequest)
		if err != nil {
			return nil, err
		}
		genericResponse, err = api.Search(searchRequest)
		resType = _searchResponse
		if err != nil {
			return nil, err
		}
	case _pullMessagesRequest:
		var pullMessagesRequest api.PullMessagesRequest
		err = json.Unmarshal(data, &pullMessagesRequest)
		if err != nil {
			return nil, err
		}
		genericResponse, err = api.PullMessages(pullMessagesRequest)
		resType = _pullMessagesResponse
		if err != nil {
			return nil, err
		}
	case _pushMessageRequest:
		var pushMessageRequest api.PushMessageRequest
		err = json.Unmarshal(data, &pushMessageRequest)
		if err != nil {
			return nil, err
		}
		genericResponse, err = api.PushMessage(pushMessageRequest)
		resType = _pushMessageResponse
		if err != nil {
			return nil, err
		}
	}

	serverTimestamp := time.Now()
	responseData, err := json.Marshal(genericResponse)
	if err != nil {
		return nil, err
	}

	return &Packet{
		Type:            string(resType),
		ServerTimestamp: &serverTimestamp,
		Data:            responseData,
	}, nil
}
