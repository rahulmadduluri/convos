package db

import (
	"log"

	"models"

	"github.com/satori/go.uuid"
)

const (
	_updateConversationTopic    = "updateConversationTopic"
	_updateTags = "updateTags"
)

func (dbh *dbHandler) UpdateConversation(conversationUUID string, topic string, timestampServer int, newTagUUID string) error {
	if topic != "" {
		_, err := dbh.db.NamedQuery(
			dbh.conversationQueries[_updateConversationTopic],
			map[string]interface{}{
				"conversation_uuid": conversationUUID,
				"topic":       topic,
			},
		)
		return err
	} else if newTagUUID != "" {
		_, err := dbh.db.NamedQuery(
			dbh.conversationQueries[_updateTags],
			map[string]interface{}{
				"conversation_uuid":               conversationUUID,
				"tag_uuid":              newTagUUID,
				"created_timestamp_server": timestampServer,
			},
		)
		return err
	}
	return nil
}

func (dbh *dbHandler) CreateConversation(
	topic string, 
	tagNames []string, 
	createdTimestampServer int, 
	photoURI string,
) error {
	groupUUIDRaw, _ := uuid.NewV4()
	groupUUID := groupUUIDRaw.String()
	conversationUUIDRaw, _ := uuid.NewV4()
	conversationUUID := conversationUUIDRaw.String()

	tx := dbh.db.MustBegin()

	q1Args := map[string]interface{}{
		"group_uuid": groupUUID,
		"name":       name,
		"created_timestamp_server": createdTimestampServer,
		"photo_uri":                photoURI,
	}
	tx.NamedExec(dbh.groupQueries[_createGroup], q1Args)

	q2Args := map[string]interface{}{
		"conversation_uuid":        conversationUUID,
		"group_uuid":               groupUUID,
		"topic":                    name,
		"created_timestamp_server": createdTimestampServer,
		"is_default":               true,
		"photo_uri":                photoURI,
	}
	tx.NamedExec(dbh.conversationQueries[_createConversation], q2Args)

	for _, mUUID := range memberUUIDs {
		q3Args := map[string]interface{}{
			"group_uuid":               groupUUID,
			"member_uuid":              mUUID,
			"created_timestamp_server": createdTimestampServer,
		}
		tx.NamedExec(dbh.groupQueries[_updateGroupMembers], q3Args)
	}

	err := tx.Commit()
	if err != nil {
		return err
	}
	return nil
}


	var tagUUIDs []string
	for _, t := range tagNames {
		tRaw, _ := uuid.NewV4()
		tUUID := tRaw.String()
		tagUUIDs = append(tagUUIDs, tUUID)
	}
