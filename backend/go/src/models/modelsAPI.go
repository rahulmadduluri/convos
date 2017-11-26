package models

import (
	"github.com/guregu/null"
)

type MessageObj struct {
	UUID                   string
	SenderUUID             string
	PhotoURL               string
	CreatedTimestampServer int
	FullText               string
	IsTopLevel             bool
	ParentUUID             null.String
}

type ConversationObj struct {
	UUID                   string
	UpdatedTimestampServer int
	Topic                  string
	IsDefault              bool
	GroupUUID              string
	GroupPhotoURL          null.String
	TopicTagUUID           string
}
