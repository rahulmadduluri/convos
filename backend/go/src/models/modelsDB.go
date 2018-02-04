package models

import (
	"github.com/guregu/null"
)

type User struct {
	ID                     int
	UUID                   string
	Username               string
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
	IsDefault              bool
	TopicTagUUID           int
	GroupID                int
}

type Group struct {
	ID                     int
	UUID                   string
	Name                   string
	CreatedTimestampServer int
	PhotoURI               null.String
}
