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

func (dbh *dbHandler) CreateGroup(groupUUID string, name string, createdTimestampServer int, photoURI string, memberUUIDs []string) error {
	_, err := dbh.db.NamedQuery(
		dbh.groupQueries[_createGroup],
		map[string]interface{}{
			"group_uuid": groupUUID,
			"name":       name,
			"created_timestamp_server": createdTimestampServer,
			"photo_uri":                photoURI,
		},
	)
	if err != nil {
		return err
	}

	for _, memberUUID := range memberUUIDs {
		_, err := dbh.db.NamedQuery(
			dbh.groupQueries[_updateGroupMembers],
			map[string]interface{}{
				"group_uuid":               groupUUID,
				"member_uuid":              memberUUID,
				"created_timestamp_server": createdTimestampServer,
			},
		)
		if err != nil {
			return err
		}
	}
	return nil
}
