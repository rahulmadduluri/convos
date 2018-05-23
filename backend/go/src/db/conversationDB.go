package db

import (
	"github.com/satori/go.uuid"
)

const (
	_updateConversationTopic = "updateConversationTopic"
	_createTag               = "createTag"
	_updateTagCount          = "updateTagCount"
	_updateConversationTags  = "updateConversationTags"
)

func (dbh *dbHandler) UpdateConversation(
	conversationUUID string,
	topic string,
	timestampServer int,
	tagName string,
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
	} else if tagName != "" {
		tx := dbh.db.MustBegin()

		// create new tag
		tRaw, _ := uuid.NewV4()
		tUUID := tRaw.String()
		q1Args := map[string]interface{}{
			"tag_uuid":                 tUUID,
			"name":                     tagName,
			"count":                    1,
			"created_timestamp_server": timestampServer,
		}
		_, err := tx.NamedExec(dbh.tagQueries[_createTag], q1Args)
		// if tag already exists, update tag count
		if err != nil {
			q2Args := map[string]interface{}{
				"name": tagName,
			}
			_, err = tx.NamedExec(dbh.tagQueries[_updateTagCount], q2Args)
			if err != nil {
				tx.Rollback()
				return err
			}
		}
		// create relationship btw tag & conversation
		q3Args := map[string]interface{}{
			"conversation_uuid": conversationUUID,
			"tag_uuid":          tUUID,
			"name":              tagName,
			"created_timestamp_server": timestampServer,
		}
		tx.NamedExec(dbh.tagQueries[_updateConversationTags], q3Args)

		err = tx.Commit()
		return err
	}
	return nil
}

func (dbh *dbHandler) CreateConversation(
	conversationUUID string,
	groupUUID string,
	topic string,
	tagNames []string,
	createdTimestampServer int,
	photoURI string,
) error {
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

	for _, name := range tagNames {
		// create new tag
		tRaw, _ := uuid.NewV4()
		tUUID := tRaw.String()
		q2Args := map[string]interface{}{
			"tag_uuid":                 tUUID,
			"name":                     name,
			"count":                    1,
			"created_timestamp_server": createdTimestampServer,
		}
		_, err := tx.NamedExec(dbh.tagQueries[_createTag], q2Args)
		// if tag already exists, update tag count
		if err != nil {
			q3Args := map[string]interface{}{
				"name": name,
			}
			_, err = tx.NamedExec(dbh.tagQueries[_updateTagCount], q3Args)
			if err != nil {
				tx.Rollback()
				return err
			}
		}
		// create relationship btw tag & conversation
		q4Args := map[string]interface{}{
			"conversation_uuid": conversationUUID,
			"tag_uuid":          tUUID,
			"name":              name,
			"created_timestamp_server": createdTimestampServer,
		}
		_, err = tx.NamedExec(dbh.tagQueries[_updateConversationTags], q4Args)
		if err != nil {
			// conversation tag relationship already exists
		}

	}

	err = tx.Commit()
	if err != nil {
		return err
	}
	return nil
}
