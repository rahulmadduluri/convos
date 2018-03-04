package db

import (
	"errors"

	"github.com/satori/go.uuid"
)

const (
	_updateConversationTopic = "updateConversationTopic"
	_createTag               = "createTag"
	_updateConversationTags  = "updateConversationTags"
)

func (dbh *dbHandler) UpdateConversation(
	conversationUUID string,
	topic string,
	timestampServer int,
	tagName string,
	newTagUUID string,
) error {
	if topic != "" {
		_, err := dbh.db.NamedQuery(
			dbh.conversationQueries[_updateConversationTopic],
			map[string]interface{}{
				"conversation_uuid": conversationUUID,
				"topic":             topic,
				"timestamp_server":  timestampServer,
			},
		)
		return err
	} else if newTagUUID != "" {
		tx := dbh.db.MustBegin()

		q1Args := map[string]interface{}{
			"tag_uuid": newTagUUID,
			"name":     tagName,
			"created_timestamp_server": timestampServer,
		}
		tx.NamedExec(dbh.tagQueries[_createTag], q1Args)

		q2Args := map[string]interface{}{
			"conversation_uuid":        conversationUUID,
			"tag_uuid":                 newTagUUID,
			"created_timestamp_server": timestampServer,
		}
		tx.NamedExec(dbh.tagQueries[_updateConversationTags], q2Args)

		err := tx.Commit()
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
	if len(tagUUIDs) != len(tagNames) {
		return errors.New("CreateConversation: Tag name count != tag UUIDs")
	}

	tx := dbh.db.MustBegin()

	q1Args := map[string]interface{}{
		"conversation_uuid":        conversationUUID,
		"group_uuid":               groupUUID,
		"topic":                    topic,
		"created_timestamp_server": createdTimestampServer,
		"photo_uri":                photoURI,
	}
	_, err := tx.NamedExec(dbh.conversationQueries[_createConversation], q1Args)
	if err != nil {
		tx.Rollback()
		return err
	}

	for i, tUUID := range tagUUIDs {
		q2Args := map[string]interface{}{
			"tag_uuid": tUUID,
			"name":     tagNames[i],
			"created_timestamp_server": createdTimestampServer,
		}
		_, err := tx.NamedExec(dbh.tagQueries[_createTag], q2Args)
		if err != nil {
			tx.Rollback()
			return err
		}

		q3Args := map[string]interface{}{
			"conversation_uuid":        conversationUUID,
			"tag_uuid":                 tUUID,
			"created_timestamp_server": createdTimestampServer,
		}
		tx.NamedExec(dbh.tagQueries[_updateConversationTags], q3Args)
		if err != nil {
			tx.Rollback()
			return err
		}
	}

	err = tx.Commit()
	if err != nil {
		return err
	}
	return nil
}
