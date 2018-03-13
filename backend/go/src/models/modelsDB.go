package models

import (
	"github.com/guregu/null"
)

type User struct {
	ID                     int
	UUID                   string
	Name                   string
	Handle                 string
	MobileNumber           string
	PhotoURI               null.String
	CreatedTimestampServer int
}

type Tag struct {
	ID                     int
	UUID                   string
	Name                   string
	IsTopic                bool
	CreatedTimestampServer int
}

type Message struct {
	ID                     int
	UUID                   string
	AllText                null.String
	CreatedTimestampServer int
	SenderID               int
	ParentID               int
}

type Conversation struct {
	ID                     int
	UUID                   string
	CreatedTimestampServer int
	UpdatedTimestampServer int
	TopicTagUUID           int
	GroupID                int
}

type Group struct {
	ID                     int
	UUID                   string
	Name                   string
	Handle                 string
	CreatedTimestampServer int
	PhotoURI               null.String
}
