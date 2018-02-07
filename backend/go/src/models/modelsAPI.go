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
	SenderPhotoURI         string
}

type ConversationObj struct {
	UUID                   string
	UpdatedTimestampServer int
	Topic                  string
	IsDefault              bool
	TopicTagUUID           string
	GroupUUID              string
	PhotoURI               null.String
}

type GroupObj struct {
	UUID          string
	Name          string
	PhotoURI      null.String
	Conversations []ConversationObj
}

type UserObj struct {
	UUID     string
	PhotoURI null.String
}
