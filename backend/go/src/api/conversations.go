package api

import (
	"db"
	"github.com/satori/go.uuid"
	"log"
	"models"
	"time"
)

var dbh = db.GetHandler()

type PullMessagesRequest struct {
	ConversationUUID      string
	LastXMessages         int
	LatestServerTimestamp *int
}

type PullMessagesResponse struct {
	Messages []models.MessageObj
	ErrorMsg *string
}

type PushMessageRequest struct {
	ConversationUUID string
	FullText         string
	SenderUUID       string
	ParentUUID       string
}

type PushMessageResponse struct {
	Message  *models.MessageObj
	ErrorMsg *string
}

func PullMessages(req PullMessagesRequest) (PullMessagesResponse, error) {
	// get last X messages before latestServerTimestamp. Returned in reverse chronological order
	log.Println(req)
	latestServerTimestamp := int(time.Now().Unix())
	if req.LatestServerTimestamp != nil {
		latestServerTimestamp = *req.LatestServerTimestamp
	}
	messages, err := dbh.GetLastXMessages(req.ConversationUUID, req.LastXMessages, latestServerTimestamp)
	if err != nil {
		log.Println("failed to get messages for req", req)
		log.Println(err)
	}
	return PullMessagesResponse{
		Messages: messages,
	}, err
}

func PushMessage(req PushMessageRequest) (PushMessageResponse, error) {
	// first add message to messages table, then add the conversation_messages relationship. DOne in single query
	log.Println(req)
	messageUUID := uuid.NewV4().String()
	err := dbh.InsertMessage(messageUUID, req.FullText, int(time.Now().Unix()), req.SenderUUID, req.ParentUUID, req.ConversationUUID)
	if err != nil {
		log.Println("failed to add message to tables", req)
		log.Println(err)
	}
	return PushMessageResponse{}, err
}
