package api

import (
	"log"
)

type PullMessagesRequest struct {
	ConversationUUID        string
	LastXMessages           int
	EarliestServerTimestamp *int
}

type PullMessagesResponse struct {
	Messages []models.Message
	ErrorMsg *string
}

type PushMessageRequest struct {
	ConversationUUID string
	FullText         string
}

type PushMessageResponse struct {
	Message  *models.Message
	ErrorMsg *string
}

type MessageObj struct {
	UUID                   string
	SenderUUID             string
	PhotoURL               string
	CreatedTimestampServer int
	FullText               string
	IsTopLevel             bool
	ParentUUID             *string
}

func PullMessages(req PullMessagesRequest) (PullMessagesResponse, error) {
	// run SQL query with request to get correct response data
	log.Println(req)
	return PullMessagesResponse{
		Messages: []MessageObj{},
	}, nil
}

func PushMessage(req PushMessageRequest) (PushMessageResponse, error) {
	// run SQL query with request to get correct response data
	log.Println(req)
	return PushMessageResponse{}, nil
}
