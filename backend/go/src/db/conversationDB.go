package db

import (
	"github.com/satori/go.uuid"
)

const (
	_updateConversationTopic = "updateConversationTopic"
	_updateTags              = "updateTags"
	_createTag               = "createTag"
)

func (dbh *dbHandler) UpdateConversation(conversationUUID string, topic string, timestampServer int, newTagUUID string) error {
	if topic != "" {
		_, err := dbh.db.NamedQuery(
			dbh.conversationQueries[_updateConversationTopic],
			map[string]interface{}{
				"conversation_uuid": conversationUUID,
				"topic":             topic,
			},
		)
		return err
	} else if newTagUUID != "" {
		_, err := dbh.db.NamedQuery(
			dbh.conversationQueries[_updateTags],
			map[string]interface{}{
				"conversation_uuid":        conversationUUID,
				"tag_uuid":                 newTagUUID,
				"created_timestamp_server": timestampServer,
			},
		)
		return err
	}
	return nil
}

func (dbh *dbHandler) CreateConversation(
	groupUUID string,
	topic string,
	tagNames []string,
	createdTimestampServer int,
	photoURI string,
) error {
	conversationUUIDRaw, _ := uuid.NewV4()
	conversationUUID := conversationUUIDRaw.String()

	var tagUUIDs []string
	for _, _ = range tagNames {
		tRaw, _ := uuid.NewV4()
		tUUID := tRaw.String()
		tagUUIDs = append(tagUUIDs, tUUID)
	}

	tx := dbh.db.MustBegin()

	q1Args := map[string]interface{}{
		"conversation_uuid":        conversationUUID,
		"group_uuid":               groupUUID,
		"topic":                    topic,
		"created_timestamp_server": createdTimestampServer,
		"is_default":               false,
		"photo_uri":                photoURI,
	}
	tx.NamedExec(dbh.conversationQueries[_createConversation], q1Args)

	for _, tUUID := range tagUUIDs {
		q2Args := map[string]interface{}{
			"conversation_uuid":        conversationUUID,
			"tag_uuid":                 tUUID,
			"created_timestamp_server": createdTimestampServer,
		}
		tx.NamedExec(dbh.tagQueries[_createTag], q2Args)
	}

	err := tx.Commit()
	if err != nil {
		return err
	}
	return nil
}
