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
	GroupUUID              string
	GroupName              string
	GroupPhotoURL          null.String
	TopicTagUUID           string
}

type UserObj struct {
	UUID string
}
