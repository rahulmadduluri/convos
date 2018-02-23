package db

import (
	"log"

	"models"
)

const (
	_findPeopleForGroup = "findPeopleForGroup"
	_updateGroupName    = "updateGroupName"
	_updateGroupMembers = "updateGroupMembers"
	_createGroup        = "createGroup"
	_createConversation = "createConversation"
	_createTag          = "createTag"
)

func (dbh *dbHandler) GetPeopleForGroup(groupUUID string, searchText string, maxPeople int) ([]models.UserObj, error) {
	var objs []models.UserObj

	wildcardSearch := "%" + searchText + "%"
	rows, err := dbh.db.NamedQuery(
		dbh.groupQueries[_findPeopleForGroup],
		map[string]interface{}{
			"group_uuid":  groupUUID,
			"search_text": wildcardSearch,
			"max_people":  maxPeople,
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

func (dbh *dbHandler) UpdateGroup(groupUUID string, name string, timestampServer int, newMemberUUID string) error {
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
	groupUUID string,
	name string,
	createdTimestampServer int,
	photoURI string,
	memberUUIDs []string,
	tagUUID string,
	conversationUUID string,
) error {
	tx := dbh.db.MustBegin()

	q1Args := map[string]interface{}{
		"group_uuid": groupUUID,
		"name":       name,
		"created_timestamp_server": createdTimestampServer,
		"photo_uri":                photoURI,
	}
	tx.NamedExec(dbh.groupQueries[_createGroup], q1Args)

	q2Args := map[string]interface{}{
		"tag_uuid":                 tagUUID,
		"name":                     name,
		"is_topic":                 true,
		"created_timestamp_server": createdTimestampServer,
	}
	tx.NamedExec(dbh.tagQueries[_createTag], q2Args)

	q3Args := map[string]interface{}{
		"conversation_uuid":        conversationUUID,
		"tag_uuid":                 tagUUID,
		"group_uuid":               groupUUID,
		"created_timestamp_server": createdTimestampServer,
		"is_default":               true,
		"photo_uri":                photoURI,
	}
	tx.NamedExec(dbh.conversationQueries[_createConversation], q3Args)

	for _, mUUID := range memberUUIDs {
		q4Args := map[string]interface{}{
			"group_uuid":               groupUUID,
			"member_uuid":              mUUID,
			"created_timestamp_server": createdTimestampServer,
		}
		tx.NamedExec(dbh.groupQueries[_updateGroupMembers], q4Args)
	}

	err := tx.Commit()
	if err != nil {
		return err
	}
	return nil
}
