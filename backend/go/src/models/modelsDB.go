package models

import (
	"github.com/guregu/null"
)

type User struct {
	ID                       int
	UUID                     string
	Username                 string
	Mobile_number            string
	Photo_url                null.String
	Created_timestamp_server int
}

type Tag struct {
	ID                       int
	UUID                     string
	Name                     string
	Is_topic                 bool
	Created_timestamp_server int
}

type Message struct {
	ID                       int
	UUID                     string
	Full_text                null.String
	Created_timestamp_server int
	Sender_id                int
	Parent_id                int
}

type Conversation struct {
	ID                       int
	UUID                     string
	Created_timestamp_server int
	Updated_timestamp_server int
	Is_default               bool
	Topic_tag_id             int
	Group_id                 int
}

type Groups struct {
	ID        int
	UUID      string
	Name      string
	Photo_url null.String
}
