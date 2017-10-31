package models

import ()

type Model interface {
	// TODO: define default model protocol
	// Should NOT abuse this
}

type User struct {
	ID                       int
	UUID                     string
	Username                 string
	Mobile_number            string
	Photo_url                *string
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
	Full_text                *string
	Created_timestamp_server int
	Parent_uuid              int
}

type Conversation struct {
	ID                       int
	UUID                     string
	Created_timestamp_server int
	Updated_timestamp_server int
	Topic_tag_uuid           int
}

type Groups struct {
	ID        int
	UUID      string
	Name      string
	Photo_url *string
}
