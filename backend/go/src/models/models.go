package models

import ()

type User struct {
	id                       int
	uuid                     string
	username                 string
	mobile_number            string
	photo_url                *string
	created_timestamp_server int64
}

type Tag struct {
	id                       int
	uuid                     string
	name                     string
	is_topic                 bool
	created_timestamp_server int64
}

type Message struct {
	id                       int
	uuid                     string
	full_text                *string
	upvotes                  int
	created_timestamp_server int64
	parent_uuid              int
}

type Conversation struct {
	id                       int
	uuid                     string
	photo_url                *string
	created_timestamp_server int64
	topic_tag_uuid           int
}
