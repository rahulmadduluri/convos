package db

import (
	"log"

	"models"

	"github.com/satori/go.uuid"
)

const (
	_findConversationsForGroup = "findConversationsForGroup"
	_findMembersForGroup       = "findMembersForGroup"
	_updateGroupName           = "updateGroupName"
	_updateGroupMembers        = "updateGroupMembers"
	_createGroup               = "createGroup"
	_createConversation        = "createConversation"
	_memberInGroup             = "groupHasMember"

	_newConversationName = "Hall"
)

func (dbh *dbHandler) IsMemberOfGroup(userUUID string, groupUUID string) (bool, error) {
	var obj models.UserObj

	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_memberInGroup],
		map[string]interface{}{
			"user_uuid":  userUUID,
			"group_uuid": groupUUID,
		},
	)
	if err != nil {
		return false, err
	}
	defer rows.Close()

	for rows.Next() {
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		return true, nil
	}
	return false, nil
}

func (dbh *dbHandler) GetConversationsForGroup(
	groupUUID string,
	maxConversations int,
) ([]models.ConversationObj, error) {
	var objs []models.ConversationObj

	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_findConversationsForGroup],
		map[string]interface{}{
			"group_uuid":        groupUUID,
			"max_conversations": maxConversations,
		},
	)

	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.ConversationObj
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		objs = append(objs, obj)
	}
	err = rows.Err()
	return objs, err
}

func (dbh *dbHandler) GetMembersForGroup(groupUUID string, searchText string, maxMembers int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_findMembersForGroup],
		map[string]interface{}{
			"group_uuid":  groupUUID,
			"search_text": wildcardSearch,
			"max_members": maxMembers,
		},
	)
	if err != nil {
		return objs, err
	}
	defer rows.Close()

	for rows.Next() {
		var obj models.UserObj
		err := rows.StructScan(&obj)
		if err != nil {
			log.Fatal("scan error: ", err)
			continue
		}
		objs = append(objs, obj)
	}
	err = rows.Err()
	return objs, err
}

func (dbh *dbHandler) UpdateGroup(
	groupUUID string,
	name string,
	timestampServer int,
	newMemberUUID string,
) error {
	if name != "" {
		_, err := dbh.db.NamedQuery(
			dbh.groupQueries[_updateGroupName],
			map[string]interface{}{
				"group_uuid": groupUUID,
				"name":       name,
			},
		)
		return err
	} else if newMemberUUID != "" {
		_, err := dbh.db.NamedQuery(
			dbh.groupQueries[_updateGroupMembers],
			map[string]interface{}{
				"group_uuid":               groupUUID,
				"member_uuid":              newMemberUUID,
				"created_timestamp_server": timestampServer,
			},
		)
		return err
	}
	return nil
}

func (dbh *dbHandler) CreateGroup(
	name string,
	handle string,
	createdTimestampServer int,
	photoURI string,
	memberUUIDs []string,
) error {
	groupUUIDRaw, _ := uuid.NewV4()
	groupUUID := groupUUIDRaw.String()
	conversationUUIDRaw, _ := uuid.NewV4()
	conversationUUID := conversationUUIDRaw.String()

	tx := dbh.db.MustBegin()

	q1Args := map[string]interface{}{
		"group_uuid":               groupUUID,
		"name":                     name,
		"handle":                   handle,
		"created_timestamp_server": createdTimestampServer,
		"photo_uri":                photoURI,
	}
	_, err := tx.NamedExec(dbh.groupQueries[_createGroup], q1Args)
	if err != nil {
		tx.Rollback()
		return err
	}

	q2Args := map[string]interface{}{
		"conversation_uuid":        conversationUUID,
		"group_uuid":               groupUUID,
		"topic":                    _newConversationName,
		"created_timestamp_server": createdTimestampServer,
		"photo_uri":                photoURI,
	}
	_, err = tx.NamedExec(dbh.conversationQueries[_createConversation], q2Args)
	if err != nil {
		tx.Rollback()
		return err
	}

	for _, mUUID := range memberUUIDs {
		q3Args := map[string]interface{}{
			"group_uuid":               groupUUID,
			"member_uuid":              mUUID,
			"created_timestamp_server": createdTimestampServer,
		}
		_, err = tx.NamedExec(dbh.groupQueries[_updateGroupMembers], q3Args)
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
