package models

import (
	"github.com/guregu/null"
)

type MessageObj struct {
	UUID                   string
	AllText                string
	CreatedTimestampServer int
	SenderUUID             string
	ParentUUID             null.String
	SenderPhotoURL         string
}

type ConversationObj struct {
	UUID                   string
	UpdatedTimestampServer int
	Topic                  string
	IsDefault              bool
	TopicTagUUID           string
}

type GroupObj struct {
	UUID          string
	Name          string
	PhotoURL      string
	Conversations []ConversationObj
}

type UserObj struct {
	UUID string
}
