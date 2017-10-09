package models

import "time"

type User struct {
	id            int
	uuid          string
	name          string
	mobile_number string
	photo_url     string
	date_created  time.Time
}

type Tags struct {
	id           int
	uuid         string
	name         string
	is_topic     bool
	date_created time.Time
}

type Messages struct {
	id           int
	uuid         string
	is_text      bool
	full_text    string
	is_link      bool
	link         string
	upvotes      int
	date_created time.Time
	sender_id    int
	parent_id    int
}

type Conversations struct {
	id           int
	uuid         string
	photo_url    string
	date_created time.Time
	topic_tag_id int
}
